
-- ============================================================
-- GharSaathi - Rental Property Management Database
-- PostgreSQL Database Schema
-- Source: GharSaathi Prisma schema (schema.prisma)
-- Total application tables: 7
-- ============================================================


-- 1. ENUM TYPES

CREATE TYPE "UserRole" AS ENUM (
    'LANDLORD',
    'TENANT'
);

CREATE TYPE "PropertyStatus" AS ENUM (
    'AVAILABLE',
    'UNAVAILABLE',
    'ARCHIVED'
);

CREATE TYPE "ApplicationStatus" AS ENUM (
    'PENDING',
    'APPROVED',
    'REJECTED'
);

CREATE TYPE "LeaseStatus" AS ENUM (
    'ACTIVE',
    'ENDED',
    'TERMINATED'
);

CREATE TYPE "PaymentStatus" AS ENUM (
    'PENDING',
    'PAID',
    'OVERDUE'
);

CREATE TYPE "MaintenanceStatus" AS ENUM (
    'OPEN',
    'IN_PROGRESS',
    'COMPLETED',
    'CLOSED'
);


-- 2. USER TABLE

CREATE TABLE "User" (
    "id" SERIAL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "role" "UserRole" NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_email_key" UNIQUE ("email")
);


-- 3. PROPERTY TABLE

CREATE TABLE "Property" (
    "id" SERIAL PRIMARY KEY,
    "landlordId" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "address" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "rent" DECIMAL(10,2) NOT NULL,
    "bedrooms" INTEGER NOT NULL,
    "bathrooms" INTEGER NOT NULL,
    "status" "PropertyStatus" NOT NULL DEFAULT 'AVAILABLE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Property_landlordId_fkey"
        FOREIGN KEY ("landlordId")
        REFERENCES "User"("id")
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


-- 4. PROPERTY IMAGE TABLE

CREATE TABLE "PropertyImage" (
    "id" SERIAL PRIMARY KEY,
    "propertyId" INTEGER NOT NULL,
    "imageUrl" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PropertyImage_propertyId_fkey"
        FOREIGN KEY ("propertyId")
        REFERENCES "Property"("id")
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- 5. APPLICATION TABLE

CREATE TABLE "Application" (
    "id" SERIAL PRIMARY KEY,
    "propertyId" INTEGER NOT NULL,
    "tenantId" INTEGER NOT NULL,
    "status" "ApplicationStatus" NOT NULL DEFAULT 'PENDING',
    "message" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Application_propertyId_fkey"
        FOREIGN KEY ("propertyId")
        REFERENCES "Property"("id")
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT "Application_tenantId_fkey"
        FOREIGN KEY ("tenantId")
        REFERENCES "User"("id")
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT "Application_propertyId_tenantId_key"
        UNIQUE ("propertyId", "tenantId")
);


-- 6. LEASE TABLE

CREATE TABLE "Lease" (
    "id" SERIAL PRIMARY KEY,
    "applicationId" INTEGER NOT NULL,
    "monthlyRent" DECIMAL(10,2) NOT NULL,
    "startDate" DATE NOT NULL,
    "endDate" DATE NOT NULL,
    "status" "LeaseStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Lease_applicationId_key" UNIQUE ("applicationId"),

    CONSTRAINT "Lease_applicationId_fkey"
        FOREIGN KEY ("applicationId")
        REFERENCES "Application"("id")
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


-- 7. PAYMENT TABLE

CREATE TABLE "Payment" (
    "id" SERIAL PRIMARY KEY,
    "leaseId" INTEGER NOT NULL,
    "amount" DECIMAL(10,2) NOT NULL,
    "dueDate" DATE NOT NULL,
    "paidDate" DATE,
    "status" "PaymentStatus" NOT NULL DEFAULT 'PENDING',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Payment_leaseId_fkey"
        FOREIGN KEY ("leaseId")
        REFERENCES "Lease"("id")
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- 8. MAINTENANCE REQUEST TABLE

CREATE TABLE "MaintenanceRequest" (
    "id" SERIAL PRIMARY KEY,
    "leaseId" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "status" "MaintenanceStatus" NOT NULL DEFAULT 'OPEN',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "MaintenanceRequest_leaseId_fkey"
        FOREIGN KEY ("leaseId")
        REFERENCES "Lease"("id")
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- 9. INDEXES

CREATE INDEX "Property_landlordId_idx"
    ON "Property"("landlordId");

CREATE INDEX "Property_city_status_idx"
    ON "Property"("city", "status");

CREATE INDEX "PropertyImage_propertyId_idx"
    ON "PropertyImage"("propertyId");

CREATE INDEX "Application_tenantId_idx"
    ON "Application"("tenantId");

CREATE INDEX "Payment_leaseId_idx"
    ON "Payment"("leaseId");

CREATE INDEX "MaintenanceRequest_leaseId_idx"
    ON "MaintenanceRequest"("leaseId");


-- ============================================================
-- END OF GHARSAATHI DATABASE SCHEMA
-- ============================================================
