# Ski Resort Management System

## Table of Contents
- [Project Overview](#project-overview)
- [Team Members](#team-members)
- [Features](#features)
- [Database Design](#database-design)
- [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgements](#acknowledgements)

## Project Overview
The Ski Resort Management System is designed to manage various operations at a ski resort, including tracking lift tickets, equipment rentals, and skier information. This project demonstrates the design and implementation of a functional database system, showcasing the integration of data analysis, modeling, and SQL scripting.

## Team Members
- **Blake Tindol**
- **Sean Deery**
- **Christian Dobish**
- **Leonard Lasek**

## Features
- **Skier Management**: Manage skier information and track their activities.
- **Ticket Sales**: Purchase and validate lift tickets.
- **Equipment Rentals**: Rent and manage ski equipment.
- **Staff Operations**: Support operations for office attendants and rental shop staff.
- **Real-Time Data Views**: Various views for monitoring resort activities and ticket validation at lift gates.

## Database Design
The project involves multiple stages of database design:
1. **Data Analysis**: Identified entities, attributes, and relationships.
2. **Conceptual Data Model**: High-level diagram representing the data model.
3. **Logical Data Model**: Detailed schema including tables and relationships.
4. **External Data Model**: Views and stored procedures for operations.

### Conceptual Model
![Conceptual Data Model](conceptual-model.png)

### Logical Model
![Logical Data Model](logical-model.png)

### External Data Model and Data Logic
- **Views**: For resort management, main office, and lift gate validation.
- **Stored Procedures**: For creating accounts, selling tickets and rentals, and managing rental operations.

## Installation
To set up the project locally using an MSSQL database and Azure Data Studio, follow these steps:

1. **Clone the repository**:
   ```bash
   git clone https://github.com/sdeery14/ski-resort-database.git
   ```

2. **Navigate to the project directory**:
   ```bash
   cd ski-resort-management
   ```

3. **Set up the database**:
   - Open Azure Data Studio and connect to your MSSQL server.
   
4. **Run the SQL scripts to set up the database schema and load initial data**:
   - Open the `ski-resort-internal-updown.sql` script in Azure Data Studio and execute it to set up the internal database schema and load the data.
   - Execute the `ski-resort-external-updown.sql` script to set up views and stored procedures:

## Usage
Once the database is set up, you can perform various operations:
1. **Selling Tickets and Rentals**:
   - Use the stored procedures `p_sell_ticket` and `p_sell_rental` to manage ticket and rental sales.
2. **Managing Rentals**:
   - Activate and deactivate rentals using `p_activate_rental` and `p_deactivate_rental`.
3. **Data Views**:
   - Access different views like `v_manager`, `v_attendant`, and `v_lift` for operational insights.

## Project Structure
- `ski-resort-external-updown.sql`: Contains SQL scripts for setting up the external side of the database database.
- `ski-resort-internal-updown.sql`: Contains SQL scripts for setting up the internal side of the database.
- `ski-resort-test-griffins.sql`: Contains SQL scripts to simulate a family visit.
- `ski-resort-database-report.docx`: Documentation including data models and project report.

## Contributing
We welcome contributions to improve the Ski Resort Management System. Please follow these steps:
1. Fork the repository.
2. Create a new branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. Commit your changes:
   ```bash
   git commit -m "Add your message"
   ```
4. Push to the branch:
   ```bash
   git push origin feature/your-feature-name
   ```
5. Create a pull request.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements
We would like to thank our course instructors and classmates for their support and collaboration throughout this project.
