# HR & Payroll Management System

A full-stack mobile application that automates HR operations including employee management, daily attendance tracking, leave approval workflows, and monthly payroll generation. Built as an end-semester project for Advanced Database Management Systems (ADBMS) and Mobile Application Development (MAD).

## Overview

This system replaces manual spreadsheet-based HR management with a connected mobile app, REST API, and NoSQL database. HR staff can manage employees, mark attendance, approve leave requests, and generate payslips in real time from an Android device.

## Tech Stack

- **Frontend:** Flutter / Dart (Material Design 3)
- **Backend:** Python Flask (REST API)
- **Database:** MongoDB
- **Architecture:** Three-tier (Mobile App → Flask API → MongoDB)

## Features

- **Employee Management** — Add, view, and delete employee profiles
- **Attendance Tracking** — Mark daily status (present / absent / half-day / leave)
- **Leave Management** — Apply, approve, or reject leave requests
- **Payroll Generation** — Auto-calculate net salary based on attendance and approved leaves
- **Payslip Generation** — Automatically generate and store payslips
- **Dashboard** — Live summary stats (total employees, present today, pending leaves, monthly payroll)
- **MongoDB Aggregation Reports** — Monthly payroll summary, attendance summary, leave statistics by department
- **Role-Based Access Control** — Admin (read/write) and Staff (read-only) MongoDB users
- **Schema Validation** — Enforced using MongoDB `$jsonSchema`
- **Indexed Queries** — Optimized with 5 indexes for fast lookups

## Database Design

6 MongoDB collections: `employees`, `departments`, `attendance`, `leaves`, `payroll`, `payslips` — using a mix of referenced and embedded document design depending on access patterns.

## Project Structure
