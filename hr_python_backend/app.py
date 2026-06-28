from flask import Flask, request, jsonify
from flask_cors import CORS
from pymongo import MongoClient
from bson import ObjectId
import json
import re

app = Flask(__name__)
CORS(app)

# MongoDB sonnection 
client = MongoClient('mongodb://localhost:27017/')
db = client['hr_payroll_db']

# converting the object ids into strings 
def clean(doc):
    if doc is None:
        return None
    doc['_id'] = str(doc['_id'])
    return doc

def clean_list(docs):
    return [clean(doc) for doc in docs]

#employees
@app.route('/employees', methods=['GET'])
def get_employees():
    docs = list(db.employees.find())
    return jsonify(clean_list(docs))

@app.route('/employees', methods=['POST'])
def add_employee():
    data = request.json

    name = data.get('name', '').strip()
    if not name:
        return jsonify({'error': 'Name is required'}), 400
    if re.search(r'[0-9]', name):
        return jsonify({'error': 'Name cannot contain numbers'}), 400
    if ' ' in name:
        return jsonify({'error': 'Name cannot contain spaces'}), 400

    phone = data.get('phone', '').strip()
    if len(phone) > 11:
        return jsonify({'error': 'Phone cannot exceed 11 digits'}), 400
    if ' ' in phone:
        return jsonify({'error': 'Phone cannot contain spaces'}), 400

    email = data.get('email', '').strip()
    if not re.match(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$', email):
        return jsonify({'error': 'Invalid email format'}), 400

    salary = data.get('basicSalary', 0)
    if float(salary) < 0:
        return jsonify({'error': 'Salary cannot be negative'}), 400

    db.employees.insert_one(data)
    return jsonify({'message': 'Employee added'})

@app.route('/employees/<emp_id>', methods=['PUT'])
def update_employee(emp_id):
    data = request.json
    db.employees.update_one(
        {'employeeId': emp_id},
        {'$set': data}
    )
    return jsonify({'message': 'Employee updated'})

@app.route('/employees/<emp_id>', methods=['DELETE'])
def delete_employee(emp_id):
    db.employees.delete_one({'employeeId': emp_id})
    return jsonify({'message': 'Employee deleted'})

#departments
@app.route('/departments', methods=['GET'])
def get_departments():
    docs = list(db.departments.find())
    return jsonify(clean_list(docs))

@app.route('/departments', methods=['POST'])
def add_department():
    data = request.json
    db.departments.insert_one(data)
    return jsonify({'message': 'Department added'})

#attendance
@app.route('/attendance', methods=['GET'])
def get_attendance():
    query = {}
    date       = request.args.get('date')
    emp_id     = request.args.get('employeeId')
    status     = request.args.get('status')
    if date:   query['date']       = date
    if emp_id: query['employeeId'] = emp_id
    if status: query['status']     = status
    docs = list(db.attendance.find(query))
    return jsonify(clean_list(docs))

@app.route('/attendance', methods=['POST'])
def mark_attendance():
    data = request.json
    existing = db.attendance.find_one({
        'employeeId': data['employeeId'],
        'date':       data['date']
    })
    if existing:
        db.attendance.update_one(
            {'employeeId': data['employeeId'], 'date': data['date']},
            {'$set': {'status': data['status']}}
        )
        return jsonify({'message': 'Attendance updated'})
    db.attendance.insert_one(data)
    return jsonify({'message': 'Attendance marked'})

#leaves
@app.route('/leaves', methods=['GET'])
def get_leaves():
    query  = {}
    emp_id = request.args.get('employeeId')
    status = request.args.get('status')
    if emp_id: query['employeeId'] = emp_id
    if status: query['status']     = status
    docs = list(db.leaves.find(query))
    return jsonify(clean_list(docs))

@app.route('/leaves', methods=['POST'])
def add_leave():
    data = request.json
    db.leaves.insert_one(data)
    return jsonify({'message': 'Leave applied'})

@app.route('/leaves/<emp_id>', methods=['PUT'])
def update_leave(emp_id):
    data = request.json
    db.leaves.update_one(
        {'employeeId': emp_id},
        {'$set': {'status': data['status']}}
    )
    return jsonify({'message': 'Leave updated'})

# payrolls

@app.route('/payroll', methods=['GET'])
def get_payroll():
    query = {}
    month  = request.args.get('month')
    emp_id = request.args.get('employeeId')
    if month:  query['month']      = month
    if emp_id: query['employeeId'] = emp_id
    docs = list(db.payroll.find(query))
    return jsonify(clean_list(docs))

@app.route('/payroll', methods=['POST'])
def add_payroll():
    data = request.json
    db.payroll.insert_one(data)
    return jsonify({'message': 'Payroll saved'})

#payslips 
@app.route('/payslips', methods=['GET'])
def get_payslips():
    query  = {}
    emp_id = request.args.get('employeeId')
    if emp_id: query['employeeId'] = emp_id
    docs = list(db.payslips.find(query))
    return jsonify(clean_list(docs))

@app.route('/payslips', methods=['POST'])
def add_payslip():
    data = request.json
    db.payslips.insert_one(data)
    return jsonify({'message': 'Payslip saved'})

#reports and aggregations

@app.route('/reports/payroll-summary', methods=['GET'])
def payroll_summary():
    month = request.args.get('month', '')
    result = list(db.payroll.aggregate([
        {'$match': {'month': month}},
        {'$group': {
            '_id':            '$month',
            'totalNetSalary': {'$sum': '$netSalary'},
            'totalEmployees': {'$sum': 1},
            'totalDeductions':{'$sum': '$deductions'}
        }}
    ]))
    return jsonify(result)

@app.route('/reports/attendance-summary', methods=['GET'])
def attendance_summary():
    result = list(db.attendance.aggregate([
        {'$group': {
            '_id':          '$employeeId',
            'employeeName': {'$first': '$employeeName'},
            'presentDays':  {'$sum': {'$cond': [{'$eq': ['$status', 'present']},  1, 0]}},
            'absentDays':   {'$sum': {'$cond': [{'$eq': ['$status', 'absent']},   1, 0]}},
            'halfDays':     {'$sum': {'$cond': [{'$eq': ['$status', 'half-day']}, 1, 0]}}
        }},
        {'$sort': {'presentDays': -1}}
    ]))
    return jsonify(result)

@app.route('/reports/leave-by-department', methods=['GET'])
def leave_by_department():
    result = list(db.leaves.aggregate([
        {'$lookup': {
            'from':         'employees',
            'localField':   'employeeId',
            'foreignField': 'employeeId',
            'as':           'empInfo'
        }},
        {'$unwind': '$empInfo'},
        {'$group': {
            '_id':           '$empInfo.departmentName',
            'totalDays':     {'$sum': '$totalDays'},
            'totalRequests': {'$sum': 1},
            'approved':      {'$sum': {'$cond': [{'$eq': ['$status', 'approved']}, 1, 0]}},
            'pending':       {'$sum': {'$cond': [{'$eq': ['$status', 'pending']},  1, 0]}}
        }},
        {'$sort': {'totalDays': -1}}
    ]))
    return jsonify(result)

#to run on server
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)