import '../model/bill.dart';
import '../model/bill_type.dart';

class Query {

  Query._();

  static String billTypeTable = '''
      CREATE TABLE IF NOT EXISTS ${BillType.tableName} (
        "id"	INTEGER NOT NULL,
        "name"	TEXT NOT NULL,
        "image"	TEXT NOT NULL,
        PRIMARY KEY("id" AUTOINCREMENT),
        UNIQUE("name")
      );
    ''';

  static String expenditureTable = '''
      CREATE TABLE IF NOT EXISTS ${Bill.tableName} (
        "id"	INTEGER NOT NULL,
        "title"	TEXT NOT NULL,
        "bill_type"	INTEGER,
        "priority"	INTEGER NOT NULL DEFAULT 0,
        "payment_type"	TEXT NOT NULL,
        "description"	TEXT,
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
      CREATE TABLE IF NOT EXISTS "expenditure_exception" (
        "id"	INTEGER NOT NULL,
        "title"	NUMERIC,
        "bill_type"	INTEGER,
        "priority"	INTEGER,
        "payment_type"	TEXT,
        "description"	TEXT,
        "payment_datetime"	TEXT,
        "expenditure_id"	NUMERIC NOT NULL,
        "amount"	NUMERIC DEFAULT 0,
        "instance_date"	TEXT,
        "deleted"	INTEGER DEFAULT 0,
        PRIMARY KEY("id" AUTOINCREMENT),
        UNIQUE ("instance_date", "expenditure_id")
      );
  ''';

  static String recurringDataForDayQuery = '''
      SELECT * FROM expenditure e WHERE (
      pattern != 0
      AND (  (datetime(end_date) >= datetime(?) AND
              datetime(strftime('%Y-%m-%d', payment_datetime)) <= datetime(?)
             )   
         OR
         (  
         SELECT CASE WHEN EXISTS(
            SELECT * FROM expenditure_exception ex 
            WHERE (
                e.id == ex.expenditure_id
                AND 
              strftime('%Y-%m-%d', ex.payment_datetime) == strftime('%Y-%m-%d', ?)
            ) 
         ) THEN CAST(1 AS BIT)
           ELSE CAST(0 AS BIT) END
         )
      ) 
      )
      UNION
      $recursionQuery
  ''';

  static String recursionQuery = '''
  SELECT -1 AS id, 
                  title, 
              bill_type, 
              priority, 
              payment_type, 
              description,
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
          WHERE
           CASE 
                WHEN pattern = 2 
                  THEN datetime(payment_datetime, '7 days')
                WHEN pattern = 3
                  THEN datetime(payment_datetime, '1 months')
                ELSE datetime(payment_datetime, '1 days')
                END
           <= datetime(end_date)
  ''';

  static String allBillAndExceptionCombined = '''
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
          
            FROM allBills r
            LEFT JOIN expenditure_exception ed
            ON strftime('%Y-%m-%d', r.payment_datetime) == strftime('%Y-%m-%d', ed.instance_date)
            AND CASE 
                  WHEN r.id == -1
                         THEN r.parent_id
                  ELSE r.id 
                  END   
            = ed.expenditure_id
  ''';

  static String billsForDayQuery([String limitQuery = '']) => '''
    WITH RECURSIVE recurringData AS (
      $recurringDataForDayQuery
    ), 
    allBills AS (
      SELECT * FROM recurringData
      UNION
      SELECT * FROM expenditure
      WHERE strftime('%Y-%m-%d', payment_datetime) = strftime('%Y-%m-%d', ?)
    ),
     allBillsAndException AS(
        $allBillAndExceptionCombined
    ), filtered AS (
      SELECT * FROM allBillsAndException WHERE (deleted IS NULL OR deleted = 0)
    )
    
    SELECT filtered.*,
           bill_type.id AS bill_type,
           bill_type.name AS bill_name,
          bill_type.image AS bill_image
    FROM filtered JOIN bill_type ON filtered.bill_type = bill_type.id
   WHERE strftime('%Y-%m-%d', payment_datetime) = strftime('%Y-%m-%d', ?)
   ORDER BY filtered.payment_datetime DESC $limitQuery;
  ''';

  static String dayHasTransactionQuery = '''
  WITH RECURSIVE recurringData AS (
      $recurringDataForDayQuery
    ), 
    allBills AS (
      SELECT * FROM recurringData
      UNION
      SELECT * FROM expenditure
      WHERE strftime('%Y-%m-%d', payment_datetime) = strftime('%Y-%m-%d', ?)
    ),
     allBillsAndException AS(
        $allBillAndExceptionCombined
    ), filtered AS (
      SELECT * FROM allBillsAndException WHERE (deleted IS NULL OR deleted = 0)
    )
    
    SELECT filtered.*,
           bill_type.id AS bill_type,
           bill_type.name AS bill_name,
           bill_type.image AS bill_image
    FROM filtered JOIN bill_type ON filtered.bill_type = bill_type.id
   WHERE strftime('%Y-%m-%d', payment_datetime) = strftime('%Y-%m-%d', ?)
   ORDER BY filtered.payment_datetime DESC LIMIT 1;
  ''';

  static String recurringDataWithQuerySpecified = '''
      SELECT * FROM expenditure e WHERE (
        pattern != 0
        AND
        (
          (   strftime(?, payment_datetime) == "'" || ? || "'"
              OR 
              strftime(?, end_date) == "'" || ? || "'"
          )
          OR 
          (  
         SELECT CASE WHEN EXISTS (
            SELECT * FROM expenditure_exception ex 
            WHERE (
                e.id == ex.expenditure_id
                AND 
              strftime(?, ex.payment_datetime) == "'" || ? || "'"
            ) 
         ) THEN CAST(1 AS BIT)
           ELSE CAST(0 AS BIT) END
         )
        )
      )
      UNION
      $recursionQuery
  ''';

  static String pieDataQuery = '''
    WITH recurringData AS (
      $recurringDataWithQuerySpecified
    ), allBills AS (
      SELECT * FROM recurringData
      UNION
      SELECT * FROM expenditure
      WHERE strftime(?, payment_datetime) = "'" || ? || "'"
    ),
     allBillsAndException AS(
        $allBillAndExceptionCombined
    ), filtered AS (
      SELECT * FROM allBillsAndException WHERE 
      (
      (deleted IS NULL OR deleted = 0)
      AND datetime(payment_datetime) <= datetime(?)
      )
    )
    
    SELECT SUM(s.amount) as amount,
      s.bill_type, bp.name as bill_name, bp.image as bill_image,
      strftime(?, payment_datetime) as date
      FROM filtered s
      JOIN bill_type bp ON
      s.bill_type = bp.id
    GROUP BY strftime(?, payment_datetime), s.bill_type
    HAVING strftime(?, s.payment_datetime) = "'" || ? || "'";
    ''';

  static String recurringDataForOverallQuery = '''
    SELECT * FROM expenditure WHERE (pattern != 0)
      UNION
    $recursionQuery
  ''';

  static String overAllPieDataQuery = '''
    WITH recurringData AS (
      $recurringDataForOverallQuery
    ) 
    , allBills AS (
      SELECT * FROM recurringData
      UNION
      SELECT * FROM expenditure WHERE datetime(payment_datetime) <= datetime(?)
      ), allBillsAndException AS(
        $allBillAndExceptionCombined
      ), filtered AS (
        SELECT * FROM allBillsAndException 
        WHERE
        (
        (deleted IS NULL OR deleted = 0)
          AND datetime(payment_datetime) <= datetime(?)
        )
     )
     
    SELECT SUM(s.amount) as amount,
      s.bill_type, bp.name as bill_name, bp.image as bill_image
    FROM filtered s
    JOIN bill_type bp ON
    s.bill_type = bp.id
    GROUP BY 2;
  ''';

  static String monthExpensesQuery = '''
    WITH recurringData AS (
      SELECT * FROM expenditure e WHERE  ( pattern != 0
      
        AND (
          (   strftime("%Y", payment_datetime) ==  ? 
              OR 
              strftime("%Y", end_date) == ?
          )
          
          OR 
          (  
         SELECT CASE WHEN EXISTS (
            SELECT * FROM expenditure_exception ex 
            WHERE (
                e.id == ex.expenditure_id
                AND 
              strftime("%Y", ex.payment_datetime) ==  ?
            ) 
         ) THEN CAST(1 AS BIT)
           ELSE CAST(0 AS BIT) END
         )
          
        )
      
     )
     UNION
     $recursionQuery
    ), allBills AS (
      SELECT * FROM recurringData
      UNION
      SELECT * FROM expenditure
      WHERE strftime("%Y", payment_datetime) = ?
    ),
     allBillsAndException AS(
        $allBillAndExceptionCombined
    ), filtered AS (
      SELECT * FROM allBillsAndException WHERE 
      (
      (deleted IS NULL OR deleted = 0)
      AND datetime(payment_datetime) <= datetime(?)
      )
    )
  
    SELECT strftime('%m',payment_datetime) as month, 
          SUM(amount) as amount
    FROM filtered
    GROUP BY strftime('%Y-%m',payment_datetime) 
    HAVING strftime('%Y',payment_datetime) = ?
    ORDER BY strftime('%m', payment_datetime) ASC;
  ''';

  static String queryForLastEndDate = '''
    WITH recurringData AS (
      SELECT * FROM expenditure WHERE
      (
       pattern != 0
       AND (id = ?)
      ) UNION
      $recursionQuery
    ), allBills AS(
      SELECT * FROM recurringData
    ),
     allBillsAndException AS(
        $allBillAndExceptionCombined
    )
    
    SELECT payment_dateTime FROM allBillsAndException
      WHERE
    datetime(payment_datetime) < datetime(?)
    ORDER BY datetime(payment_datetime) DESC;
  ''';

  static String queryForFinancials = '''
     WITH recurringData AS (
      SELECT * FROM expenditure e WHERE  ( pattern != 0
      
        AND (
          (   strftime("%Y", payment_datetime) ==  ? 
              OR 
              strftime("%Y", end_date) == ?
          )
          OR 
          (  
         SELECT CASE WHEN EXISTS (
            SELECT * FROM expenditure_exception ex 
            WHERE (
                e.id == ex.expenditure_id
                AND 
              strftime("%Y", ex.payment_datetime) ==  ?
            ) 
         ) THEN CAST(1 AS BIT)
           ELSE CAST(0 AS BIT) END
         )
          
        )
      
     )
     UNION
     $recursionQuery
     ), allBills AS (
      SELECT * FROM recurringData
      UNION
      SELECT * FROM expenditure
      WHERE strftime("%Y-%m", payment_datetime) = ?
    ), allBillsAndException AS(
        $allBillAndExceptionCombined
    ), filtered AS (
      SELECT * FROM allBillsAndException WHERE 
      (
      (deleted IS NULL OR deleted = 0)
      AND datetime(payment_datetime) <= datetime(?)
      )
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
      FROM filtered 
      GROUP BY 2
      HAVING strftime('%Y-%m', payment_datetime) = ?) t 
      on t.date = strftime('%Y-%m', b.date) 
      WHERE strftime('%Y-%m', b.date) = ?;
  ''';

  static String queryForFirstInsert = '''
   WITH savedData AS (
    SELECT * FROM expenditure ORDER BY datetime(payment_datetime) ASC LIMIT 1
   ), allData AS (
     SELECT payment_datetime FROM savedData UNION
     SELECT payment_datetime FROM expenditure_exception WHERE (deleted IS NULL OR deleted = 0) 
   )
  
  SELECT payment_datetime FROM allData ORDER BY
     datetime(payment_datetime) ASC LIMIT 1;
  ''';
}
