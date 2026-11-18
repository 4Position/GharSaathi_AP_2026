-- ============================================================
-- GHARSAATHI - CP3: APPLICATION DATABASE QUERIES
-- File: dbms/04_queries.sql
--
-- Source: Backend service methods in MVP_GHARSAATHI.
-- These are representative PostgreSQL equivalents of the Prisma
-- operations used by the application. Prisma may emit different SQL.
--
-- Parameter convention:
--   $1, $2, ... are positional parameters supplied by the application.
--   Enum values are cast to the corresponding PostgreSQL enum type.
--
-- READ queries are labelled R1, R2, ...
-- WRITE queries are labelled W1, W2, ...
--
-- Note:
--   Authentication hashing, JWT creation, role checks, and some
--   ownership/business-rule checks happen in application code.
--   They are not represented as SQL unless they perform DB access.
-- ============================================================


-- ============================================================
-- READ QUERIES
-- ============================================================

-- R1: Health check - verify database connectivity
SELECT 1;


-- R2: Registration - check whether an email already exists
SELECT "id"
FROM "User"
WHERE "email" = $1
LIMIT 1;


-- R3: Login - retrieve user by email, including password hash
-- Password comparison and JWT generation happen in application code.
SELECT
    "id",
    "name",
    "email",
    "passwordHash",
    "role",
    "createdAt",
    "updatedAt"
FROM "User"
WHERE "email" = $1
LIMIT 1;


-- R4: Get the current user's profile
SELECT
    "id",
    "name",
    "email",
    "role",
    "createdAt",
    "updatedAt"
FROM "User"
WHERE "id" = $1
LIMIT 1;


-- R5: Get a property by ID, with its images and landlord details
SELECT
    p."id" AS "propertyId",
    p."title",
    p."description",
    p."address",
    p."city",
    p."rent",
    p."bedrooms",
    p."bathrooms",
    p."status",
    p."createdAt",
    p."updatedAt",
    pi."id" AS "imageId",
    pi."imageUrl",
    pi."createdAt" AS "imageCreatedAt",
    landlord."id" AS "landlordId",
    landlord."name" AS "landlordName"
FROM "Property" p
LEFT JOIN "PropertyImage" pi
    ON pi."propertyId" = p."id"
LEFT JOIN "User" landlord
    ON landlord."id" = p."landlordId"
WHERE p."id" = $1
ORDER BY pi."createdAt" ASC;


-- R6: Check property ownership before landlord-only operations
SELECT
    "id",
    "landlordId"
FROM "Property"
WHERE "id" = $1
LIMIT 1;


-- R7: List available properties with optional filters
-- Parameters:
--   $1 = city (NULL means no city filter)
--   $2 = minimum rent (NULL means no minimum)
--   $3 = maximum rent (NULL means no maximum)
--   $4 = bedrooms (NULL means no bedroom filter)
SELECT
    p."id" AS "propertyId",
    p."title",
    p."description",
    p."address",
    p."city",
    p."rent",
    p."bedrooms",
    p."bathrooms",
    p."status",
    p."createdAt",
    pi."id" AS "imageId",
    pi."imageUrl",
    landlord."id" AS "landlordId",
    landlord."name" AS "landlordName"
FROM "Property" p
LEFT JOIN "PropertyImage" pi
    ON pi."propertyId" = p."id"
LEFT JOIN "User" landlord
    ON landlord."id" = p."landlordId"
WHERE p."status" = 'AVAILABLE'::"PropertyStatus"
  AND ($1::TEXT IS NULL OR LOWER(p."city") = LOWER($1))
  AND ($2::DECIMAL IS NULL OR p."rent" >= $2)
  AND ($3::DECIMAL IS NULL OR p."rent" <= $3)
  AND ($4::INTEGER IS NULL OR p."bedrooms" = $4)
ORDER BY p."createdAt" DESC, pi."createdAt" ASC;


-- R8: List properties owned by a landlord
SELECT
    p."id" AS "propertyId",
    p."title",
    p."description",
    p."address",
    p."city",
    p."rent",
    p."bedrooms",
    p."bathrooms",
    p."status",
    p."createdAt",
    pi."id" AS "imageId",
    pi."imageUrl",
    landlord."id" AS "landlordId",
    landlord."name" AS "landlordName"
FROM "Property" p
LEFT JOIN "PropertyImage" pi
    ON pi."propertyId" = p."id"
LEFT JOIN "User" landlord
    ON landlord."id" = p."landlordId"
WHERE p."landlordId" = $1
ORDER BY p."createdAt" DESC, pi."createdAt" ASC;


-- R9: Verify property exists and is available before application submission
SELECT
    "id",
    "status"
FROM "Property"
WHERE "id" = $1
LIMIT 1;


-- R10: List applications submitted by a tenant
SELECT
    a."id" AS "applicationId",
    a."status" AS "applicationStatus",
    a."message",
    a."createdAt" AS "applicationCreatedAt",
    a."updatedAt" AS "applicationUpdatedAt",
    p."id" AS "propertyId",
    p."title",
    p."address",
    p."city",
    p."rent",
    p."status" AS "propertyStatus",
    pi."id" AS "imageId",
    pi."imageUrl",
    tenant."id" AS "tenantId",
    tenant."name" AS "tenantName",
    tenant."email" AS "tenantEmail"
FROM "Application" a
INNER JOIN "Property" p
    ON p."id" = a."propertyId"
LEFT JOIN "PropertyImage" pi
    ON pi."propertyId" = p."id"
INNER JOIN "User" tenant
    ON tenant."id" = a."tenantId"
WHERE a."tenantId" = $1
ORDER BY a."createdAt" DESC, pi."createdAt" ASC;


-- R11: List applications received by a landlord
SELECT
    a."id" AS "applicationId",
    a."status" AS "applicationStatus",
    a."message",
    a."createdAt" AS "applicationCreatedAt",
    p."id" AS "propertyId",
    p."title",
    p."address",
    p."city",
    p."rent",
    pi."id" AS "imageId",
    pi."imageUrl",
    tenant."id" AS "tenantId",
    tenant."name" AS "tenantName",
    tenant."email" AS "tenantEmail"
FROM "Application" a
INNER JOIN "Property" p
    ON p."id" = a."propertyId"
LEFT JOIN "PropertyImage" pi
    ON pi."propertyId" = p."id"
INNER JOIN "User" tenant
    ON tenant."id" = a."tenantId"
WHERE p."landlordId" = $1
ORDER BY a."createdAt" DESC, pi."createdAt" ASC;


-- R12: Get an application and verify that it belongs to landlord's property
SELECT
    a."id" AS "applicationId",
    a."propertyId",
    a."tenantId",
    a."status",
    p."landlordId"
FROM "Application" a
INNER JOIN "Property" p
    ON p."id" = a."propertyId"
WHERE a."id" = $1
LIMIT 1;


-- R13: Check whether the property already has an active lease
-- Used while approving an application.
SELECT l."id"
FROM "Lease" l
INNER JOIN "Application" a
    ON a."id" = l."applicationId"
WHERE a."propertyId" = $1
  AND l."status" = 'ACTIVE'::"LeaseStatus"
LIMIT 1;


-- R14: Get an approved application with its property and any existing lease
-- Used before creating a lease.
SELECT
    a."id" AS "applicationId",
    a."propertyId",
    a."tenantId",
    a."status" AS "applicationStatus",
    p."landlordId",
    p."rent",
    l."id" AS "leaseId",
    l."status" AS "leaseStatus"
FROM "Application" a
INNER JOIN "Property" p
    ON p."id" = a."propertyId"
LEFT JOIN "Lease" l
    ON l."applicationId" = a."id"
WHERE a."id" = $1
LIMIT 1;


-- R15: Check for an active lease on the property before lease creation
SELECT l."id"
FROM "Lease" l
INNER JOIN "Application" a
    ON a."id" = l."applicationId"
WHERE a."propertyId" = $1
  AND l."status" = 'ACTIVE'::"LeaseStatus"
LIMIT 1;


-- R16: List leases for the logged-in landlord or tenant
-- Parameters:
--   $1 = role ('LANDLORD' or 'TENANT')
--   $2 = logged-in user ID
SELECT
    l."id" AS "leaseId",
    l."monthlyRent",
    l."startDate",
    l."endDate",
    l."status" AS "leaseStatus",
    l."createdAt" AS "leaseCreatedAt",
    a."id" AS "applicationId",
    a."tenantId",
    p."id" AS "propertyId",
    p."title",
    p."address",
    p."city",
    p."landlordId",
    tenant."name" AS "tenantName",
    tenant."email" AS "tenantEmail",
    landlord."name" AS "landlordName",
    landlord."email" AS "landlordEmail"
FROM "Lease" l
INNER JOIN "Application" a
    ON a."id" = l."applicationId"
INNER JOIN "Property" p
    ON p."id" = a."propertyId"
INNER JOIN "User" tenant
    ON tenant."id" = a."tenantId"
INNER JOIN "User" landlord
    ON landlord."id" = p."landlordId"
WHERE
    ($1 = 'LANDLORD' AND p."landlordId" = $2)
    OR
    ($1 = 'TENANT' AND a."tenantId" = $2)
ORDER BY l."createdAt" DESC;


-- R17: Get a lease with related property, landlord, and tenant details
-- Application code performs the final role/ownership authorization check.
SELECT
    l."id" AS "leaseId",
    l."applicationId",
    l."monthlyRent",
    l."startDate",
    l."endDate",
    l."status" AS "leaseStatus",
    a."tenantId",
    p."id" AS "propertyId",
    p."title",
    p."address",
    p."city",
    p."landlordId",
    pi."id" AS "imageId",
    pi."imageUrl",
    tenant."id" AS "tenantId",
    tenant."name" AS "tenantName",
    tenant."email" AS "tenantEmail",
    landlord."id" AS "landlordId",
    landlord."name" AS "landlordName",
    landlord."email" AS "landlordEmail"
FROM "Lease" l
INNER JOIN "Application" a
    ON a."id" = l."applicationId"
INNER JOIN "Property" p
    ON p."id" = a."propertyId"
LEFT JOIN "PropertyImage" pi
    ON pi."propertyId" = p."id"
INNER JOIN "User" tenant
    ON tenant."id" = a."tenantId"
INNER JOIN "User" landlord
    ON landlord."id" = p."landlordId"
WHERE l."id" = $1
ORDER BY pi."createdAt" ASC;


-- R18: Get lease and property ownership details before status update
SELECT
    l."id" AS "leaseId",
    l."status" AS "leaseStatus",
    a."propertyId",
    p."landlordId"
FROM "Lease" l
INNER JOIN "Application" a
    ON a."id" = l."applicationId"
INNER JOIN "Property" p
    ON p."id" = a."propertyId"
WHERE l."id" = $1
LIMIT 1;


-- R19: Check for another active lease on the same property
-- $1 = property ID, $2 = current lease ID to exclude
SELECT l."id"
FROM "Lease" l
INNER JOIN "Application" a
    ON a."id" = l."applicationId"
WHERE a."propertyId" = $1
  AND l."status" = 'ACTIVE'::"LeaseStatus"
  AND l."id" <> $2
LIMIT 1;


-- R20: Get lease/application information before a tenant creates maintenance request
SELECT
    l."id" AS "leaseId",
    l."status" AS "leaseStatus",
    a."tenantId",
    a."propertyId"
FROM "Lease" l
INNER JOIN "Application" a
    ON a."id" = l."applicationId"
WHERE l."id" = $1
LIMIT 1;


-- R21: List maintenance requests for the logged-in landlord or tenant
-- Parameters: $1 = role, $2 = logged-in user ID
SELECT
    mr."id" AS "maintenanceRequestId",
    mr."title",
    mr."description",
    mr."status" AS "maintenanceStatus",
    mr."createdAt" AS "requestCreatedAt",
    l."id" AS "leaseId",
    l."status" AS "leaseStatus",
    a."tenantId",
    p."id" AS "propertyId",
    p."title" AS "propertyTitle",
    p."address",
    p."city",
    p."landlordId",
    tenant."name" AS "tenantName",
    tenant."email" AS "tenantEmail"
FROM "MaintenanceRequest" mr
INNER JOIN "Lease" l
    ON l."id" = mr."leaseId"
INNER JOIN "Application" a
    ON a."id" = l."applicationId"
INNER JOIN "Property" p
    ON p."id" = a."propertyId"
INNER JOIN "User" tenant
    ON tenant."id" = a."tenantId"
WHERE
    ($1 = 'LANDLORD' AND p."landlordId" = $2)
    OR
    ($1 = 'TENANT' AND a."tenantId" = $2)
ORDER BY mr."createdAt" DESC;


-- R22: Get a maintenance request and verify landlord ownership
SELECT
    mr."id" AS "maintenanceRequestId",
    mr."status",
    l."id" AS "leaseId",
    p."landlordId"
FROM "MaintenanceRequest" mr
INNER JOIN "Lease" l
    ON l."id" = mr."leaseId"
INNER JOIN "Application" a
    ON a."id" = l."applicationId"
INNER JOIN "Property" p
    ON p."id" = a."propertyId"
WHERE mr."id" = $1
LIMIT 1;


-- R23: Get lease information before creating a payment
SELECT
    l."id" AS "leaseId",
    l."monthlyRent",
    a."tenantId",
    p."landlordId",
    p."id" AS "propertyId",
    p."title" AS "propertyTitle"
FROM "Lease" l
INNER JOIN "Application" a
    ON a."id" = l."applicationId"
INNER JOIN "Property" p
    ON p."id" = a."propertyId"
WHERE l."id" = $1
LIMIT 1;


-- R24: List payments for the logged-in landlord or tenant
-- Parameters: $1 = role, $2 = logged-in user ID
SELECT
    pay."id" AS "paymentId",
    pay."amount",
    pay."dueDate",
    pay."paidDate",
    pay."status" AS "paymentStatus",
    pay."createdAt" AS "paymentCreatedAt",
    l."id" AS "leaseId",
    l."monthlyRent",
    a."tenantId",
    p."id" AS "propertyId",
    p."title" AS "propertyTitle",
    p."address",
    p."city",
    p."landlordId",
    tenant."name" AS "tenantName",
    tenant."email" AS "tenantEmail"
FROM "Payment" pay
INNER JOIN "Lease" l
    ON l."id" = pay."leaseId"
INNER JOIN "Application" a
    ON a."id" = l."applicationId"
INNER JOIN "Property" p
    ON p."id" = a."propertyId"
INNER JOIN "User" tenant
    ON tenant."id" = a."tenantId"
WHERE
    ($1 = 'LANDLORD' AND p."landlordId" = $2)
    OR
    ($1 = 'TENANT' AND a."tenantId" = $2)
ORDER BY pay."dueDate" DESC, pay."createdAt" DESC;


-- R25: Get payment and related ownership details before status update
SELECT
    pay."id" AS "paymentId",
    pay."status" AS "paymentStatus",
    pay."leaseId",
    l."id" AS "leaseId",
    a."tenantId",
    p."landlordId"
FROM "Payment" pay
INNER JOIN "Lease" l
    ON l."id" = pay."leaseId"
INNER JOIN "Application" a
    ON a."id" = l."applicationId"
INNER JOIN "Property" p
    ON p."id" = a."propertyId"
WHERE pay."id" = $1
LIMIT 1;


-- ============================================================
-- WRITE QUERIES
-- ============================================================

-- W1: Register a new user
-- Password is already hashed by the backend before this INSERT.
INSERT INTO "User" (
    "name",
    "email",
    "passwordHash",
    "role",
    "updatedAt"
)
VALUES (
    $1,
    $2,
    $3,
    $4::"UserRole",
    CURRENT_TIMESTAMP
)
RETURNING
    "id",
    "name",
    "email",
    "role",
    "createdAt",
    "updatedAt";


-- W2: Create a property and its images
-- Execute this complete block as one transaction.
-- $1..$7 = landlordId, title, description, address, city, rent, bedrooms
-- $8 = bathrooms
-- Supply one W2 image INSERT for each image URL returned by the frontend.
BEGIN;

WITH new_property AS (
    INSERT INTO "Property" (
        "landlordId",
        "title",
        "description",
        "address",
        "city",
        "rent",
        "bedrooms",
        "bathrooms",
        "status",
        "updatedAt"
    )
    VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8,
        'AVAILABLE'::"PropertyStatus",
        CURRENT_TIMESTAMP
    )
    RETURNING "id"
)
SELECT "id" AS "newPropertyId"
FROM new_property;

-- W2-image: run once per image URL, using the new property ID as $1
-- and image URL as $2.
-- INSERT INTO "PropertyImage" ("propertyId", "imageUrl")
-- VALUES ($1, $2)
-- RETURNING *;

COMMIT;


-- W3: Update property details
UPDATE "Property"
SET
    "title" = $2,
    "description" = $3,
    "address" = $4,
    "city" = $5,
    "rent" = $6,
    "bedrooms" = $7,
    "bathrooms" = $8,
    "updatedAt" = CURRENT_TIMESTAMP
WHERE "id" = $1
  AND "landlordId" = $9
RETURNING *;


-- W3-image replacement: execute only when imageUrls are supplied.
-- Run the DELETE and all replacement INSERTs in the same transaction.
-- $1 = property ID, $2 = landlord ID
-- DELETE FROM "PropertyImage"
-- WHERE "propertyId" = $1
--   AND EXISTS (
--       SELECT 1 FROM "Property"
--       WHERE "id" = $1 AND "landlordId" = $2
--   );
-- Then INSERT each replacement image:
-- INSERT INTO "PropertyImage" ("propertyId", "imageUrl")
-- VALUES ($1, $3)
-- RETURNING *;


-- W4: Update property availability/status
UPDATE "Property"
SET
    "status" = $2::"PropertyStatus",
    "updatedAt" = CURRENT_TIMESTAMP
WHERE "id" = $1
  AND "landlordId" = $3
RETURNING *;


-- W5: Submit a rental application
INSERT INTO "Application" (
    "propertyId",
    "tenantId",
    "message",
    "status",
    "updatedAt"
)
VALUES (
    $1,
    $2,
    $3,
    'PENDING'::"ApplicationStatus",
    CURRENT_TIMESTAMP
)
RETURNING *;


-- W6: Approve or reject an application
UPDATE "Application"
SET
    "status" = $2::"ApplicationStatus",
    "updatedAt" = CURRENT_TIMESTAMP
WHERE "id" = $1
RETURNING *;


-- W7: Create a lease
-- The backend performs application approval, landlord ownership,
-- existing-lease checks, and property-rent lookup in a SERIALIZABLE
-- transaction before this INSERT.
INSERT INTO "Lease" (
    "applicationId",
    "monthlyRent",
    "startDate",
    "endDate",
    "status",
    "updatedAt"
)
VALUES (
    $1,
    $2,
    $3,
    $4,
    'ACTIVE'::"LeaseStatus",
    CURRENT_TIMESTAMP
)
RETURNING *;


-- W8: Update lease status
UPDATE "Lease" AS l
SET
    "status" = $2::"LeaseStatus",
    "updatedAt" = CURRENT_TIMESTAMP
FROM "Application" AS a
INNER JOIN "Property" AS p
    ON p."id" = a."propertyId"
WHERE l."applicationId" = a."id"
  AND l."id" = $1
  AND p."landlordId" = $3
RETURNING l.*;


-- W9: Create a maintenance request
-- The backend verifies tenant ownership and that the lease is ACTIVE.
INSERT INTO "MaintenanceRequest" (
    "leaseId",
    "title",
    "description",
    "status",
    "updatedAt"
)
VALUES (
    $1,
    $2,
    $3,
    'OPEN'::"MaintenanceStatus",
    CURRENT_TIMESTAMP
)
RETURNING *;


-- W10: Update maintenance request status
UPDATE "MaintenanceRequest" AS mr
SET
    "status" = $2::"MaintenanceStatus",
    "updatedAt" = CURRENT_TIMESTAMP
FROM "Lease" AS l
INNER JOIN "Application" AS a
    ON a."id" = l."applicationId"
INNER JOIN "Property" AS p
    ON p."id" = a."propertyId"
WHERE mr."leaseId" = l."id"
  AND mr."id" = $1
  AND p."landlordId" = $3
RETURNING mr.*;


-- W11: Create a payment
-- Backend verifies landlord ownership and uses the lease monthlyRent.
INSERT INTO "Payment" (
    "leaseId",
    "amount",
    "dueDate",
    "status",
    "updatedAt"
)
VALUES (
    $1,
    $2,
    $3,
    'PENDING'::"PaymentStatus",
    CURRENT_TIMESTAMP
)
RETURNING *;


-- W12: Update payment status and paid date
-- $1 = payment ID, $2 = new status, $3 = landlord ID
UPDATE "Payment" AS pay
SET
    "status" = $2::"PaymentStatus",
    "paidDate" = CASE
        WHEN $2::"PaymentStatus" = 'PAID'::"PaymentStatus"
        THEN CURRENT_DATE
        ELSE NULL
    END,
    "updatedAt" = CURRENT_TIMESTAMP
FROM "Lease" AS l
INNER JOIN "Application" AS a
    ON a."id" = l."applicationId"
INNER JOIN "Property" AS p
    ON p."id" = a."propertyId"
WHERE pay."leaseId" = l."id"
  AND pay."id" = $1
  AND p."landlordId" = $3
RETURNING pay.*;


-- ============================================================
-- END OF CP3 QUERY CATALOGUE
-- ============================================================
