// import ballerina/io;
import ballerinax/mysql;
import ballerina/sql;

configurable string dbName = ?;
configurable string dbPassword = ?;
configurable string dbUser = ?;
configurable string dbhost = ?;

// mysql:Client dbClient = check new (host = dbhost, user = dbUser, password = dbPassword, database = dbName, port = 3306);
final mysql:Client dbClient = check new(
    host=dbhost, user=dbUser, password=dbPassword, port=3306, database=dbName
);

public type Employee record {|
    int EmployeeNumber?;
    string FirstName;
    string LastName;
    string Email;
    string Salary;
|};

isolated function addEmployee(Employee emp) returns int|error {
    sql:ExecutionResult result = check dbClient->execute(`
        INSERT INTO Employees (EmployeeNumber, FirstName, LastName, Email, Salary,
                               hire_date, manager_id, job_title)
        VALUES (${emp.EmployeeNumber}, ${emp.FirstName}, ${emp.LastName},  
                ${emp.Email})
    `);
    int|string? lastInsertId = result.lastInsertId;
    if lastInsertId is int {
        return lastInsertId;
    } else {
        return error("Unable to obtain last insert ID");
    }
}

isolated function getEmployee(int id) returns Employee|error {
    Employee employee = check dbClient->queryRow(
        `SELECT * FROM Employees WHERE EmployeeNumber = ${id}`
    );
    return employee;
}

isolated function getAllEmployees() returns Employee[]|error {
    Employee[] employees = [];
    stream<Employee, error?> resultStream = dbClient->query(
        `SELECT * FROM Employees`
    );
    check from Employee employee in resultStream
        do {
            employees.push(employee);
        };
    check resultStream.close();
    return employees;
}

isolated function updateEmployee(Employee emp) returns int|error {
    sql:ExecutionResult result = check dbClient->execute(`
        UPDATE Employees SET
            FirstName = ${emp.FirstName}, 
            LastName = ${emp.LastName},
            Email = ${emp.Email},
            Salary = ${emp.Salary}
        WHERE EmployeeNumber = ${emp.EmployeeNumber}  
    `);
    int|string? lastInsertId = result.lastInsertId;
    if lastInsertId is int {
        return lastInsertId;
    } else {
        return error("Unable to obtain last insert ID");
    }
}

isolated function removeEmployee(int id) returns int|error {
    sql:ExecutionResult result = check dbClient->execute(`
        DELETE FROM Employees WHERE EmployeeNumber = ${id}
    `);
    int? affectedRowCount = result.affectedRowCount;
    if affectedRowCount is int {
        return affectedRowCount;
    } else {
        return error("Unable to obtain the affected row count");
    }
}

// public function main() {
//     io:println("Hello, World!");
// }
