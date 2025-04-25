# InjecPro – Injection Production System

**InjecPro** is a web-based system developed for **plastic injection molding manufacturers** to manage **production costs**, plan production, and track **inventory** automatically based on logged output. This system integrates SQL Server with Flask APIs and a Bootstrap-styled frontend.

---

## 🚀 Features

- **Product Costing**  
  - Input raw materials and operational data  
  - Calculate total material costs, operational costs, and final unit cost  
  - Maintain historical cost records for auditing and analysis  

- **Production Planning**  
  - Forecast material requirements for planned production batches  
  - Automatically calculate estimated production hours based on operational data (e.g., cycle time, cavities)  

- **Inventory Management**  
  - Display planned vs. produced quantities with real-time remaining stock  
  - Employees log daily production outputs (quantities produced and hours worked)  
  - Auto-update inventory records after logging production  

- **User Roles & Permissions**  
  - **Admin:** Full access (product management, costing, planning, inventory, user management)  
  - **Employee:** Limited access (log production only)  

- **Security**  
  - Role-based access control  
  - Password hashing using **bcrypt**

---

## 🔧 Technologies Used

- **Frontend**: HTML, Bootstrap, JavaScript  
- **Backend**: Python (Flask)  
- **Database**: SQL Server (SSMS)

---
## 📄 License

Educational project for database implementation course.
