class Query {
  static String billTypeTable = '''
      CREATE TABLE "bill_type" (
        "id"	INTEGER NOT NULL,
        "name"	TEXT NOT NULL,
        "image"	TEXT NOT NULL,
        PRIMARY KEY("id" AUTOINCREMENT)
      );
    ''';

  static String expenditureTable = '''
      CREATE TABLE "expenditure" (
        "id"	INTEGER NOT NULL,
        "title"	TEXT NOT NULL,
        "bill_type"	INTEGER,
        "priority"	INTEGER NOT NULL DEFAULT 0,
        "payment_type"	INTEGER NOT NULL,
        "description"	TEXT,
        "is_recurring"	INTEGER NOT NULL DEFAULT 0,
        "pattern"	INTEGER,
        "parent_id"	INTEGER,
        "payment_datetime"	TEXT NOT NULL,
        "amount"	INTEGER NOT NULL DEFAULT 0,
        "end_date"	TEXT,
        PRIMARY KEY("id" AUTOINCREMENT)
      );
    ''';

  static String budgetTable = '''
        CREATE TABLE IF NOT EXISTS budget (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL UNIQUE,
          amount INTEGER NOT NULL
       );
    ''';

  static String expenditureExceptionTable = '''
      CREATE TABLE "expenditure_exception" (
        "id"	INTEGER NOT NULL,
        "title"	NUMERIC,
        "bill_type"	INTEGER,
        "priority"	INTEGER,
        "payment_type"	INTEGER,
        "description"	TEXT,
        "payment_datetime"	TEXT,
        "expenditure_id"	NUMERIC NOT NULL,
        "amount"	NUMERIC DEFAULT 0,
        "instance_date"	INTEGER,
        "deleted"	INTEGER DEFAULT 0,
        PRIMARY KEY("id" AUTOINCREMENT),
        UNIQUE ("instance_date", "expenditure_id")
    );
  ''';

  static String generateRecursionQuery = '''
        WITH RECURSIVE recurringData AS (
           SELECT * FROM expenditure
           UNION 
           SELECT -1 AS id, 
                  title, 
              bill_type, 
              priority, 
              payment_type, 
              description,
              is_recurring,
              pattern,
              CASE WHEN recurringData.id = -1
              THEN recurringData.parent_id
              ELSE recurringData.id END AS parent_id,
              CASE 
                WHEN pattern = 2 
                  THEN datetime(payment_datetime, '7 days')
                WHEN pattern = 3
                  THEN datetime(payment_datetime, '1 months')
                ELSE datetime(payment_datetime, '1 days')
                END
              AS payment_datetime,
              amount,
              end_date
          FROM recurringData 
          WHERE is_recurring = 1 AND
           CASE 
                WHEN pattern = 2 
                  THEN datetime(payment_datetime, '7 days')
                WHEN pattern = 3
                  THEN datetime(payment_datetime, '1 months')
                ELSE datetime(payment_datetime, '1 days')
                END
           <= datetime(end_date)
          ),
          generatedData AS (
            SELECT
               r.id,	
             
            CASE WHEN ed.title IS NOT NULL 
              THEN ed.title
            ELSE r.title END AS title,
            
            CASE WHEN ed.bill_type IS NOT NULL 
              THEN ed.bill_type
            ELSE r.bill_type END AS bill_type,
            
            CASE WHEN ed.priority IS NOT NULL 
              THEN ed.priority
            ELSE r.priority END AS priority,
            
            CASE WHEN ed.payment_type IS NOT NULL 
              THEN ed.payment_type
            ELSE r.payment_type END AS payment_type,
            
            CASE WHEN ed.description IS NOT NULL 
              THEN ed.description
            ELSE r.description END AS description,
            
            r.is_recurring,
            
            r.pattern,
            
            r.parent_id,
            
            CASE WHEN ed.payment_datetime IS NOT NULL 
              THEN ed.payment_datetime
            ELSE r.payment_datetime END AS payment_datetime,
            
            CASE WHEN ed.amount IS NOT NULL 
              THEN ed.amount
            ELSE r.amount END AS amount,
            
            ed.id AS exception_id,
            
            r.end_date,
            
            ed.deleted
          
            FROM recurringData r
            LEFT JOIN expenditure_exception ed
            ON strftime('%Y-%m-%d', r.payment_datetime) == ed.instance_date 
            AND CASE 
                  WHEN r.id == -1
                         THEN r.parent_id
                  ELSE r.id 
                  END   
            = ed.expenditure_id
      ), resolvedData AS (
          SELECT * FROM generatedData WHERE deleted IS NULL OR deleted = 0
      )
  ''';

  static String financialsQuery = '''
   $generateRecursionQuery,
   secondResolved AS (
      SELECT * FROM resolvedData WHERE datetime(payment_datetime) < datetime(?)
    )
    SELECT b.amount as budget,
            CASE 
              WHEN  b.amount - t.amount_spent   IS NULL THEN b.amount
              ELSE (b.amount - t.amount_spent) 
              END as balance,
            CASE
              WHEN t.amount_spent IS NULL THEN 0 
              ELSE t.amount_spent
              END as amount_spent  
      FROM budget b 
      LEFT JOIN 
      (SELECT SUM(amount) as amount_spent, 
              strftime('%Y-%m', payment_datetime) as date 
      FROM secondResolved 
      GROUP BY 2
      HAVING strftime('%Y-%m', payment_datetime) = ?) t 
      on t.date = strftime('%Y-%m', b.date) 
      WHERE strftime('%Y-%m', b.date) = ?;
  ''';

  static String getMonthSpendingQuery() {
    return '''
    $generateRecursionQuery,
    secondResolved AS (
      SELECT * FROM resolvedData WHERE datetime(payment_datetime) < datetime(?)
    )
    SELECT strftime('%m',payment_datetime) as month, 
          SUM(amount) as amount
    FROM secondResolved
    GROUP BY strftime('%Y-%m',payment_datetime) 
    HAVING strftime('%Y',payment_datetime) = ?
    ORDER BY strftime('%m', payment_datetime) ASC;
    ''';
  }

  static String getExpenditureWithLimitQuery() {
    return '''
    $generateRecursionQuery
    SELECT resolvedData.*, 
           bill_type.id AS bill_type, 
           bill_type.name AS bill_name,
           bill_type.image AS bill_image
    FROM resolvedData JOIN bill_type ON resolvedData.bill_type = bill_type.id
    WHERE strftime('%Y-%m-%d', payment_datetime) = ?
    AND datetime(payment_datetime) <= datetime(?)
    ORDER BY resolvedData.payment_datetime DESC LIMIT ?;
    ''';
  }

  static String expenditureByDateQuery = '''
    $generateRecursionQuery
    SELECT resolvedData.*, 
           bill_type.id AS bill_type, 
           bill_type.name AS bill_name,
           bill_type.image AS bill_image
    FROM resolvedData JOIN bill_type ON resolvedData.bill_type = bill_type.id
    WHERE strftime('%Y-%m-%d', payment_datetime) = ?
    ORDER BY resolvedData.payment_datetime DESC;
  ''';

  static String didTransactionOccurQuery = '''
    $generateRecursionQuery
     
     SELECT * FROM resolvedData 
     WHERE strftime('%Y-%m-%d', payment_datetime) = ?
     LIMIT 1;
  ''';

  static String overallPieDataQuery =
    '''
    $generateRecursionQuery,
    secondResolved AS (
      SELECT * FROM resolvedData WHERE datetime(payment_datetime) < datetime(?)
    )
      SELECT SUM(s.amount) as amount,
        s.bill_type, bp.name as bill_name, bp.image as bill_image
      FROM secondResolved s
      JOIN bill_type bp ON
      s.bill_type = bp.id
      GROUP BY 2;
    ''';

  static String pieQuery(String format, String date) => '''
    $generateRecursionQuery,
    secondResolved AS (
      SELECT * FROM resolvedData WHERE datetime(payment_datetime) < datetime(?)
    )
   
    SELECT SUM(s.amount) as amount,
           s.bill_type, bp.name as bill_name, bp.image as bill_image,
           strftime($format, payment_datetime) as date
     FROM secondResolved s
     JOIN bill_type bp ON
     s.bill_type = bp.id
     GROUP BY strftime($format, payment_datetime), s.bill_type HAVING strftime($format, s.payment_datetime) = '$date';
  ''';
}
