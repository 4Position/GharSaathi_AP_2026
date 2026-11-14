# GharSaathi — Database Design and Normalization

**Project:** GharSaathi
**Database:** PostgreSQL
**Document:** Initial Database Design and Normalization
**Status:** Proposed MVP Database Design

---

# 1. Introduction

GharSaathi is a rental property management platform that connects landlords and tenants.

The application will allow:

- Landlords to register and list rental properties.
- Tenants to browse properties and submit rental applications.
- Landlords to approve or reject applications.
- Approved applications to be converted into rental leases.
- Tenants to track their rent payments.
- Tenants to raise maintenance requests.

The objective of this document is to identify the database tables required by the application, define their attributes and relationships, and demonstrate how the database design follows normalization principles (1NF, 2NF and 3NF).

**Database:** PostgreSQL

**ORM:** Prisma (to be implemented later)

---

# 2. Identification of Database Tables

Based on the application's requirements, we have identified the following seven tables.

| No. | Table Name           | Purpose                                        |
| --- | -------------------- | ---------------------------------------------- |
| 1   | users                | Stores landlord and tenant account information |
| 2   | properties           | Stores rental property details                 |
| 3   | property_images      | Stores images associated with properties       |
| 4   | applications         | Stores tenant applications for properties      |
| 5   | leases               | Stores rental agreement information            |
| 6   | payments             | Stores rent payment records                    |
| 7   | maintenance_requests | Stores maintenance requests raised by tenants  |

## 2.1 Users Table

Stores information about all registered users, including landlords and tenants.

| Attribute     | Description                     |
| ------------- | ------------------------------- |
| user_id       | Unique identifier for each user |
| full_name     | Full name of the user           |
| email         | Email address used for login    |
| password_hash | Hashed password                 |
| phone         | Contact number                  |
| role          | LANDLORD or TENANT              |
| created_at    | Account creation timestamp      |
| updated_at    | Last update timestamp           |

## 2.2 Properties Table

Stores information about rental properties listed by landlords.

| Attribute     | Description                                |
| ------------- | ------------------------------------------ |
| property_id   | Unique property identifier                 |
| landlord_id   | ID of the landlord who listed the property |
| title         | Property listing title                     |
| description   | Property description                       |
| property_type | Apartment, house, etc.                     |
| rent_amount   | Monthly rental amount                      |
| address_line  | Property street address                    |
| city          | City                                       |
| state         | State                                      |
| pincode       | Postal code                                |
| bedrooms      | Number of bedrooms                         |
| bathrooms     | Number of bathrooms                        |
| status        | AVAILABLE, RENTED or INACTIVE              |
| created_at    | Listing creation timestamp                 |
| updated_at    | Last update timestamp                      |

## 2.3 Property Images Table

A property can have multiple images. Therefore, images are stored separately.

| Attribute   | Description                         |
| ----------- | ----------------------------------- |
| image_id    | Unique image identifier             |
| property_id | ID of the associated property       |
| image_url   | Image URL or storage path           |
| is_primary  | Whether the image is the main image |
| created_at  | Image creation timestamp            |

## 2.4 Applications Table

Stores rental applications submitted by tenants.

| Attribute      | Description                           |
| -------------- | ------------------------------------- |
| application_id | Unique application identifier         |
| property_id    | Property for which the tenant applied |
| tenant_id      | ID of the tenant who applied          |
| message        | Application message                   |
| status         | PENDING, APPROVED or REJECTED         |
| applied_at     | Application submission timestamp      |
| reviewed_at    | Application review timestamp          |

## 2.5 Leases Table

Stores rental agreement information after an application is approved.

| Attribute      | Description                     |
| -------------- | ------------------------------- |
| lease_id       | Unique lease identifier         |
| application_id | ID of the approved application  |
| monthly_rent   | Agreed monthly rent             |
| start_date     | Lease starting date             |
| end_date       | Lease ending date               |
| status         | ACTIVE, COMPLETED or TERMINATED |
| created_at     | Lease creation timestamp        |

## 2.6 Payments Table

Stores rent payment records associated with leases.

| Attribute             | Description                   |
| --------------------- | ----------------------------- |
| payment_id            | Unique payment identifier     |
| lease_id              | ID of the associated lease    |
| amount                | Payment amount                |
| due_date              | Rent payment due date         |
| paid_at               | Payment timestamp             |
| status                | PENDING, PAID or OVERDUE      |
| payment_method        | Payment method                |
| transaction_reference | Payment transaction reference |
| created_at            | Record creation timestamp     |

## 2.7 Maintenance Requests Table

Stores maintenance issues reported by tenants during their lease.

| Attribute   | Description                           |
| ----------- | ------------------------------------- |
| request_id  | Unique maintenance request identifier |
| lease_id    | ID of the associated lease            |
| title       | Maintenance request title             |
| description | Description of the issue              |
| status      | PENDING, IN_PROGRESS or RESOLVED      |
| created_at  | Request creation timestamp            |
| updated_at  | Last update timestamp                 |
| resolved_at | Resolution timestamp                  |

---

# 3. Initial Database Design (Before Normalization)

Initially, consider a single combined relation that stores property information, landlord details, property images and tenant applications together.

This represents a poorly structured database design in which information about different entities is stored in one relation.

### INITIAL_RENTAL_RECORD

| property_id | property_title    | landlord_id | landlord_name | landlord_email                                 | city  |  rent | images                 | tenant_applications   |
| ----------- | ----------------- | ----------- | ------------- | ---------------------------------------------- | ----- | ----: | ---------------------- | --------------------- |
| P101        | Green Residency   | U01         | Rahul Sharma  | [rahul@example.com](mailto\:rahul@example.com) | Delhi | 18000 | p101_1.jpg, p101_2.jpg | U02\:Priya, U03\:Aman |
| P102        | Sunrise Apartment | U01         | Rahul Sharma  | [rahul@example.com](mailto\:rahul@example.com) | Noida | 22000 | p102_1.jpg, p102_2.jpg | U02\:Priya            |

### Problems with the initial design

1. The `images` column contains multiple values in a single cell.
2. The `tenant_applications` column contains multiple application records in a single cell.
3. Landlord information is repeated for multiple properties.
4. Application information is mixed with property information.
5. Updating or deleting individual images and applications becomes difficult.
6. Repeated information can lead to insertion, update and deletion anomalies.

We will normalize this design step by step.

---

# 4. First Normal Form (1NF)

A table satisfies First Normal Form when:

- Every cell contains a single atomic value.
- There are no multi-valued attributes or repeating groups.
- Every row can be uniquely identified.

### Problem in the initial design

The `images` and `tenant_applications` columns contain multiple values in a single cell.

Therefore, the initial relation does not satisfy 1NF.

### Conversion into 1NF

We separate the multiple image and application values into individual rows.

### RENTAL_RECORD_1NF

| property_id | image_url  | tenant_id | tenant_name | application_status | property_title    | landlord_id | landlord_name | landlord_email                                 | city  |  rent |
| ----------- | ---------- | --------- | ----------- | ------------------ | ----------------- | ----------- | ------------- | ---------------------------------------------- | ----- | ----: |
| P101        | p101_1.jpg | U02       | Priya       | PENDING            | Green Residency   | U01         | Rahul Sharma  | [rahul@example.com](mailto\:rahul@example.com) | Delhi | 18000 |
| P101        | p101_2.jpg | U02       | Priya       | PENDING            | Green Residency   | U01         | Rahul Sharma  | [rahul@example.com](mailto\:rahul@example.com) | Delhi | 18000 |
| P101        | p101_1.jpg | U03       | Aman        | APPROVED           | Green Residency   | U01         | Rahul Sharma  | [rahul@example.com](mailto\:rahul@example.com) | Delhi | 18000 |
| P101        | p101_2.jpg | U03       | Aman        | APPROVED           | Green Residency   | U01         | Rahul Sharma  | [rahul@example.com](mailto\:rahul@example.com) | Delhi | 18000 |
| P102        | p102_1.jpg | U02       | Priya       | PENDING            | Sunrise Apartment | U01         | Rahul Sharma  | [rahul@example.com](mailto\:rahul@example.com) | Noida | 22000 |
| P102        | p102_2.jpg | U02       | Priya       | PENDING            | Sunrise Apartment | U01         | Rahul Sharma  | [rahul@example.com](mailto\:rahul@example.com) | Noida | 22000 |

Now every cell contains a single value.

For this illustrative relation, we assume the candidate key is:

`(property_id, image_url, tenant_id)`

This combination identifies each property-image-tenant record under the assumptions that image URLs are unique within a property and a tenant can apply only once to a property.

### Functional Dependencies

- `property_id → property_title, landlord_id, landlord_name, landlord_email, city, rent`
- `landlord_id → landlord_name, landlord_email`
- `(property_id, tenant_id) → tenant_name, application_status`
- `(property_id, image_url) → image_url`

### Result

The relation now satisfies 1NF because all attributes contain atomic values.

However, it does not satisfy 2NF because some non-key attributes depend only on part of the composite candidate key.

For example:

`property_id → property_title, city, rent`

Property information depends only on `property_id`, not on the complete composite key.

This is called a **partial dependency**.

---

# 5. Second Normal Form (2NF)

A table satisfies Second Normal Form when:

- It is already in 1NF.
- Every non-key attribute depends on the complete candidate key.
- There are no partial dependencies.

### Problem in RENTAL_RECORD_1NF

The candidate key is:

`(property_id, image_url, tenant_id)`

However:

- Property details depend only on `property_id`.
- Image details depend on `(property_id, image_url)`.
- Application details depend on `(property_id, tenant_id)`.
- Landlord details depend on `landlord_id`.

Therefore, the original relation contains partial dependencies.

### Decomposition into separate tables

We separate the combined relation into the following tables.

### 5.1 PROPERTY_2NF

| property_id (PK) | property_title    | landlord_id | landlord_name | landlord_email                                 | city  |  rent |
| ---------------- | ----------------- | ----------- | ------------- | ---------------------------------------------- | ----- | ----: |
| P101             | Green Residency   | U01         | Rahul Sharma  | [rahul@example.com](mailto\:rahul@example.com) | Delhi | 18000 |
| P102             | Sunrise Apartment | U01         | Rahul Sharma  | [rahul@example.com](mailto\:rahul@example.com) | Noida | 22000 |

### 5.2 PROPERTY_IMAGE_2NF

| property_id (PK, FK) | image_url (PK) |
| -------------------- | -------------- |
| P101                 | p101_1.jpg     |
| P101                 | p101_2.jpg     |
| P102                 | p102_1.jpg     |
| P102                 | p102_2.jpg     |

### 5.3 APPLICATION_2NF

| property_id (PK, FK) | tenant_id (PK, FK) | application_status |
| -------------------- | ------------------ | ------------------ |
| P101                 | U02                | PENDING            |
| P101                 | U03                | APPROVED           |
| P102                 | U02                | PENDING            |

### 5.4 TENANT_2NF

| tenant_id (PK) | tenant_name |
| -------------- | ----------- |
| U02            | Priya       |
| U03            | Aman        |

### Result

The partial dependencies from the original combined relation have been removed.

- Property information is stored in `PROPERTY_2NF`.
- Image information is stored in `PROPERTY_IMAGE_2NF`.
- Application information is stored in `APPLICATION_2NF`.
- Tenant names are stored separately in `TENANT_2NF`.

However, `PROPERTY_2NF` still contains landlord name and email along with `landlord_id`.

The following dependency exists:

- `property_id → landlord_id`
- `landlord_id → landlord_name, landlord_email`

Therefore:

`property_id → landlord_id → landlord_name, landlord_email`

This is a **transitive dependency**.

We need to remove this dependency to achieve 3NF.

---

# 6. Third Normal Form (3NF)

A table satisfies Third Normal Form when:

- It is already in 2NF.
- It does not contain transitive dependencies of non-key attributes on a candidate key.

### Problem in PROPERTY_2NF

Landlord details are stored in the property table even though they depend on `landlord_id`.

Similarly, tenant information should not be duplicated in the application table.

### Solution: Create a separate USERS table

Instead of maintaining separate landlord and tenant tables, GharSaathi will use one common `users` table.

The `role` attribute will identify whether a user is a landlord or a tenant.

### 6.1 USERS

| user_id (PK) | full_name    | email                                          | role     |
| ------------ | ------------ | ---------------------------------------------- | -------- |
| U01          | Rahul Sharma | [rahul@example.com](mailto\:rahul@example.com) | LANDLORD |
| U02          | Priya Verma  | [priya@example.com](mailto\:priya@example.com) | TENANT   |
| U03          | Aman Kumar   | [aman@example.com](mailto\:aman@example.com)   | TENANT   |

### 6.2 PROPERTIES

| property_id (PK) | landlord_id (FK) | property_title    | city  |  rent |
| ---------------- | ---------------- | ----------------- | ----- | ----: |
| P101             | U01              | Green Residency   | Delhi | 18000 |
| P102             | U01              | Sunrise Apartment | Noida | 22000 |

### 6.3 PROPERTY_IMAGES

| image_id (PK) | property_id (FK) | image_url  |
| ------------- | ---------------- | ---------- |
| I101          | P101             | p101_1.jpg |
| I102          | P101             | p101_2.jpg |
| I103          | P102             | p102_1.jpg |
| I104          | P102             | p102_2.jpg |

### 6.4 APPLICATIONS

| application_id (PK) | property_id (FK) | tenant_id (FK) | status   |
| ------------------- | ---------------- | -------------- | -------- |
| A101                | P101             | U02            | PENDING  |
| A102                | P101             | U03            | APPROVED |
| A103                | P102             | U02            | PENDING  |

### Result

Now:

- Landlord information is stored in `USERS`.
- Tenant information is stored in `USERS`.
- Property information is stored in `PROPERTIES`.
- Images are stored in `PROPERTY_IMAGES`.
- Application information is stored in `APPLICATIONS`.

The property table stores only `landlord_id`, and the application table stores only `tenant_id`.

User information can be retrieved through foreign-key relationships using JOIN operations.

This removes the transitive dependency identified in the previous design.

The remaining tables (`LEASES`, `PAYMENTS` and `MAINTENANCE_REQUESTS`) are also designed separately because they represent different entities and their own attributes.

**Result: The proposed database design satisfies 3NF under the functional dependencies defined in this document.**

---

# 7. Final Normalized Database Schema

After normalization, the following seven tables will form the initial database schema for GharSaathi.

These are the tables that will be used to create the ER diagram and later implemented using PostgreSQL and Prisma.

## 7.1 USERS

Stores information about landlords and tenants.

| Column        | PostgreSQL Data Type | Constraints                         |
| ------------- | -------------------- | ----------------------------------- |
| user_id       | UUID                 | PRIMARY KEY                         |
| full_name     | VARCHAR(100)         | NOT NULL                            |
| email         | VARCHAR(255)         | UNIQUE, NOT NULL                    |
| password_hash | TEXT                 | NOT NULL                            |
| phone         | VARCHAR(20)          | NULL                                |
| role          | VARCHAR(20)          | NOT NULL                            |
| created_at    | TIMESTAMP            | NOT NULL, DEFAULT CURRENT_TIMESTAMP |
| updated_at    | TIMESTAMP            | NOT NULL                            |

**Candidate Keys:** `user_id`, `email`

**Role values:** `LANDLORD`, `TENANT`

## 7.2 PROPERTIES

Stores rental property listings.

| Column        | PostgreSQL Data Type | Constraints                           |
| ------------- | -------------------- | ------------------------------------- |
| property_id   | UUID                 | PRIMARY KEY                           |
| landlord_id   | UUID                 | FOREIGN KEY → users.user_id, NOT NULL |
| title         | VARCHAR(150)         | NOT NULL                              |
| description   | TEXT                 | NULL                                  |
| property_type | VARCHAR(30)          | NOT NULL                              |
| rent_amount   | NUMERIC(10,2)        | NOT NULL, CHECK > 0                   |
| address_line  | TEXT                 | NOT NULL                              |
| city          | VARCHAR(100)         | NOT NULL                              |
| state         | VARCHAR(100)         | NOT NULL                              |
| pincode       | VARCHAR(10)          | NOT NULL                              |
| bedrooms      | SMALLINT             | NOT NULL, CHECK >= 0                  |
| bathrooms     | SMALLINT             | NOT NULL, CHECK >= 0                  |
| status        | VARCHAR(20)          | NOT NULL                              |
| created_at    | TIMESTAMP            | NOT NULL, DEFAULT CURRENT_TIMESTAMP   |
| updated_at    | TIMESTAMP            | NOT NULL                              |

**Candidate Key:** `property_id`

**Status values:** `AVAILABLE`, `RENTED`, `INACTIVE`

## 7.3 PROPERTY_IMAGES

Stores images belonging to properties.

| Column      | PostgreSQL Data Type | Constraints                                    |
| ----------- | -------------------- | ---------------------------------------------- |
| image_id    | UUID                 | PRIMARY KEY                                    |
| property_id | UUID                 | FOREIGN KEY → properties.property_id, NOT NULL |
| image_url   | TEXT                 | NOT NULL                                       |
| is_primary  | BOOLEAN              | NOT NULL, DEFAULT FALSE                        |
| created_at  | TIMESTAMP            | NOT NULL, DEFAULT CURRENT_TIMESTAMP            |

**Candidate Key:** `image_id`

## 7.4 APPLICATIONS

Stores tenant applications.

| Column         | PostgreSQL Data Type | Constraints                                    |
| -------------- | -------------------- | ---------------------------------------------- |
| application_id | UUID                 | PRIMARY KEY                                    |
| property_id    | UUID                 | FOREIGN KEY → properties.property_id, NOT NULL |
| tenant_id      | UUID                 | FOREIGN KEY → users.user_id, NOT NULL          |
| message        | TEXT                 | NULL                                           |
| status         | VARCHAR(20)          | NOT NULL                                       |
| applied_at     | TIMESTAMP            | NOT NULL, DEFAULT CURRENT_TIMESTAMP            |
| reviewed_at    | TIMESTAMP            | NULL                                           |

**Candidate Keys:** `application_id`, `(property_id, tenant_id)`

**Additional Constraint:** `UNIQUE(property_id, tenant_id)`

**Status values:** `PENDING`, `APPROVED`, `REJECTED`

## 7.5 LEASES

Stores rental agreement information.

| Column         | PostgreSQL Data Type | Constraints                                                 |
| -------------- | -------------------- | ----------------------------------------------------------- |
| lease_id       | UUID                 | PRIMARY KEY                                                 |
| application_id | UUID                 | FOREIGN KEY → applications.application_id, UNIQUE, NOT NULL |
| monthly_rent   | NUMERIC(10,2)        | NOT NULL, CHECK > 0                                         |
| start_date     | DATE                 | NOT NULL                                                    |
| end_date       | DATE                 | NOT NULL                                                    |
| status         | VARCHAR(20)          | NOT NULL                                                    |
| created_at     | TIMESTAMP            | NOT NULL, DEFAULT CURRENT_TIMESTAMP                         |

**Candidate Keys:** `lease_id`, `application_id`

**Status values:** `ACTIVE`, `COMPLETED`, `TERMINATED`

The agreed rent is stored in the lease because it may differ from the currently advertised property rent.

## 7.6 PAYMENTS

Stores rent payment records.

| Column                | PostgreSQL Data Type | Constraints                             |
| --------------------- | -------------------- | --------------------------------------- |
| payment_id            | UUID                 | PRIMARY KEY                             |
| lease_id              | UUID                 | FOREIGN KEY → leases.lease_id, NOT NULL |
| amount                | NUMERIC(10,2)        | NOT NULL, CHECK > 0                     |
| due_date              | DATE                 | NOT NULL                                |
| paid_at               | TIMESTAMP            | NULL                                    |
| status                | VARCHAR(20)          | NOT NULL                                |
| payment_method        | VARCHAR(30)          | NULL                                    |
| transaction_reference | VARCHAR(150)         | NULL                                    |
| created_at            | TIMESTAMP            | NOT NULL, DEFAULT CURRENT_TIMESTAMP     |

**Candidate Keys:** `payment_id`, `(lease_id, due_date)`

**Additional Constraint:** `UNIQUE(lease_id, due_date)`

**Status values:** `PENDING`, `PAID`, `OVERDUE`

## 7.7 MAINTENANCE_REQUESTS

Stores maintenance requests raised by tenants.

| Column      | PostgreSQL Data Type | Constraints                             |
| ----------- | -------------------- | --------------------------------------- |
| request_id  | UUID                 | PRIMARY KEY                             |
| lease_id    | UUID                 | FOREIGN KEY → leases.lease_id, NOT NULL |
| title       | VARCHAR(150)         | NOT NULL                                |
| description | TEXT                 | NOT NULL                                |
| status      | VARCHAR(20)          | NOT NULL                                |
| created_at  | TIMESTAMP            | NOT NULL, DEFAULT CURRENT_TIMESTAMP     |
| updated_at  | TIMESTAMP            | NOT NULL                                |
| resolved_at | TIMESTAMP            | NULL                                    |

**Candidate Key:** `request_id`

**Status values:** `PENDING`, `IN_PROGRESS`, `RESOLVED`

---

# 8. Relationships Between Tables

The following relationships define how the seven tables are connected.

| Parent Table | Child Table          | Relationship       | Foreign Key                   |
| ------------ | -------------------- | ------------------ | ----------------------------- |
| users        | properties           | One-to-Many        | properties.landlord_id        |
| properties   | property_images      | One-to-Many        | property_images.property_id   |
| users        | applications         | One-to-Many        | applications.tenant_id        |
| properties   | applications         | One-to-Many        | applications.property_id      |
| applications | leases               | One-to-Zero-or-One | leases.application_id         |
| leases       | payments             | One-to-Many        | payments.lease_id             |
| leases       | maintenance_requests | One-to-Many        | maintenance_requests.lease_id |

### Explanation

1. One landlord can list multiple properties.
2. One property can contain multiple images.
3. One tenant can submit multiple applications.
4. One property can receive applications from multiple tenants.
5. One approved application can result in at most one lease.
6. One lease can have multiple payment records.
7. One lease can have multiple maintenance requests.

The `applications` table connects tenants and properties and represents their application relationship.

---

# 9. Normalization Summary

The following table summarizes the normal forms achieved by the final database design.

| Table                | 1NF | 2NF | 3NF |
| -------------------- | --- | --- | --- |
| users                | Yes | Yes | Yes |
| properties           | Yes | Yes | Yes |
| property_images      | Yes | Yes | Yes |
| applications         | Yes | Yes | Yes |
| leases               | Yes | Yes | Yes |
| payments             | Yes | Yes | Yes |
| maintenance_requests | Yes | Yes | Yes |

### 1NF

All columns contain atomic values. Multiple images are stored as separate rows in `property_images`, and multiple applications are stored as separate rows in `applications`.

### 2NF

Partial dependencies are removed by decomposing the original combined relation into separate property, image and application relations.

Tables with a single-column candidate key cannot have partial dependencies on a part of that key.

### 3NF

Transitive dependencies are removed by separating user information from property and application information.

For example:

`property_id → landlord_id`

`landlord_id → landlord_name, landlord_email`

Landlord details are therefore stored in `users`, rather than repeated in `properties`.

### BCNF

BCNF requires every determinant in every non-trivial functional dependency to be a superkey.

Under the functional dependencies and candidate keys declared in this document, the proposed relations satisfy BCNF. This conclusion depends on the stated uniqueness and business-rule assumptions. If new functional dependencies are introduced in future, the schema should be reviewed again.

---

# 10. Database Integrity Constraints

The following rules must be enforced through database constraints and backend logic:

1. Every user must have a unique email address.
2. A user must have either the LANDLORD or TENANT role.
3. Only landlords can create and manage their own property listings.
4. A tenant cannot apply for the same property more than once.
5. Every application must reference an existing tenant and property.
6. Only approved applications can be converted into leases.
7. One application can create at most one lease.
8. A property must not have multiple active leases simultaneously.
9. Every payment must reference an existing lease.
10. Every maintenance request must reference an existing lease.
11. Rent and payment amounts must be greater than zero.
12. Foreign-key relationships must remain valid.

Some business rules, such as checking whether a user is a landlord or whether an application is approved, also require backend authorization and transaction logic. A foreign key alone cannot enforce these rules.

---

# 11. Conclusion

The initial GharSaathi database design consists of seven relational tables:

1. users
2. properties
3. property_images
4. applications
5. leases
6. payments
7. maintenance_requests

The database normalization process separates repeating and duplicated information into appropriate relations.

The final design follows 1NF, 2NF and 3NF under the functional dependencies and candidate keys defined in this document.

This schema will serve as the starting point for creating the ER diagram, PostgreSQL tables and Prisma models.

As development progresses, any changes in application requirements will be reflected through updated database documentation and migrations.
