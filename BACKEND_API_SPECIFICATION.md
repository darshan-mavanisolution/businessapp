# BizFinder / Businessmen App - Backend API Specification (v1.0)

This document provides complete technical specifications for backend developers to implement all REST APIs required by the **BizFinder (Businessmen)** Flutter mobile application.

---

## 1. General Architecture & Standards

- **Base URL**: `https://api.yourdomain.com/api/v1`
- **Protocol**: HTTPS only
- **Data Format**: `application/json` (except file uploads which use `multipart/form-data`)
- **Authentication**: JWT Bearer Token passed in headers:
  ```http
  Authorization: Bearer <access_token>
  ```
- **Time Format**: ISO 8601 UTC string (e.g. `2026-10-05T12:00:00Z`)

### Standard Response Envelope

#### Success Response
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": { ... }
}
```

#### Paginated Success Response
```json
{
  "success": true,
  "message": "Data retrieved successfully",
  "data": [ ... ],
  "meta": {
    "total": 140,
    "page": 1,
    "limit": 20,
    "totalPages": 7
  }
}
```

#### Error Response
```json
{
  "success": false,
  "message": "Detailed error message",
  "errorCode": "INVALID_OTP",
  "errors": {
    "field": "Validation message"
  }
}
```

---

## 2. Core Data Models

### 2.1 User Model
```json
{
  "id": "usr_987654",
  "name": "Darshan Pambhar",
  "email": "darshan.pambhar@gmail.com",
  "phoneNumber": "+91 98765 43210",
  "avatarUrl": "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=600&auto=format&fit=crop&q=80",
  "createdAt": "2026-10-01T10:00:00Z"
}
```

### 2.2 City Model
```json
{
  "id": "surat",
  "name": "Surat",
  "state": "Gujarat",
  "imageUrl": "https://images.unsplash.com/photo-1545645648-524cba4655f4?w=600&auto=format&fit=crop&q=80",
  "businessCount": "120+"
}
```

### 2.3 Sector Model
```json
{
  "id": "sec_1",
  "name": "Sector 1",
  "cityId": "surat",
  "businessCount": "120+ Businesses"
}
```

### 2.4 Category Model
```json
{
  "id": "doctor",
  "name": "Doctors",
  "subtitle": "Find trusted doctors near you",
  "iconUrl": "https://assets.yourdomain.com/icons/doctor.png",
  "colorHex": "#3B82F6",
  "businessCount": "45+"
}
```

### 2.5 Business Model
```json
{
  "id": "doc_1",
  "name": "Dr. Jignesh Patel",
  "category": "Doctors",
  "specialty": "General Physician",
  "description": "Experienced General Physician providing comprehensive healthcare services for all age groups.",
  "imageUrl": "https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=800&auto=format&fit=crop&q=80",
  "phoneNumber": "+91 98765 43210",
  "whatsappNumber": "+919876543210",
  "email": "dr.jignesh@gmail.com",
  "rating": 4.8,
  "reviewCount": 120,
  "city": "Surat",
  "sector": "Sector 1",
  "address": "123, City Light Road, Surat - 395007",
  "latitude": 21.1702,
  "longitude": 72.8311,
  "distance": "2.3 km",
  "openingTime": "09:00 AM",
  "closingTime": "08:00 PM",
  "isOpen": true,
  "avatarInitials": "JP",
  "specializations": [
    "General Checkup",
    "Diabetes",
    "Hypertension",
    "Fever & Infection"
  ],
  "businessName": "Patel Healthcare Clinic",
  "personalPhone": "+91 98765 43210",
  "personalEmail": "dr.jignesh@gmail.com",
  "businessPhone": "+91 261 2456789",
  "businessEmail": "info@patelclinic.com",
  "isFavorite": false
}
```

---

## 3. Detailed API Endpoints

### 3.1 Authentication & Profile APIs

#### `POST /auth/send-otp`
Sends a 6-digit OTP to the user's email address.
- **Auth**: None (Public)
- **Request Body**:
  ```json
  {
    "email": "user@example.com"
  }
  ```
- **Response `200 OK`**:
  ```json
  {
    "success": true,
    "message": "OTP has been sent to user@example.com",
    "data": {
      "resendCountdown": 30
    }
  }
  ```

---

#### `POST /auth/verify-otp`
Verifies the 6-digit OTP and logs the user in (or signs them up if not yet registered).
- **Auth**: None (Public)
- **Request Body**:
  ```json
  {
    "email": "user@example.com",
    "otp": "123456"
  }
  ```
- **Response `200 OK`**:
  ```json
  {
    "success": true,
    "message": "Login successful",
    "data": {
      "accessToken": "eyJhbGciOi...",
      "refreshToken": "eyJhbGciOi...",
      "user": {
        "id": "usr_1",
        "name": "Darshan Pambhar",
        "email": "user@example.com",
        "phoneNumber": "+91 98765 43210",
        "avatarUrl": "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=600&auto=format&fit=crop&q=80"
      }
    }
  }
  ```

---

#### `POST /auth/google` & `POST /auth/apple`
Social Sign-in verification.
- **Auth**: None (Public)
- **Request Body (Google)**:
  ```json
  {
    "idToken": "google_oauth_id_token"
  }
  ```
- **Request Body (Apple)**:
  ```json
  {
    "identityToken": "apple_identity_token",
    "authorizationCode": "apple_auth_code",
    "fullName": "Optional Apple Name"
  }
  ```
- **Response `200 OK`**: Same token and user payload as verify-otp.

---

#### `POST /auth/refresh-token`
Generates a new access token when expired.
- **Auth**: None
- **Request Body**:
  ```json
  {
    "refreshToken": "eyJhbGciOi..."
  }
  ```
- **Response `200 OK`**:
  ```json
  {
    "success": true,
    "data": {
      "accessToken": "new_jwt_access_token",
      "refreshToken": "new_or_existing_refresh_token"
    }
  }
  ```

---

#### `GET /user/profile`
Retrieves current user details.
- **Auth**: Required (`Bearer <token>`)
- **Response `200 OK`**:
  ```json
  {
    "success": true,
    "data": {
      "id": "usr_1",
      "name": "Darshan Pambhar",
      "email": "darshan.pambhar@gmail.com",
      "phoneNumber": "+91 98765 43210",
      "avatarUrl": "https://..."
    }
  }
  ```

---

#### `PUT /user/profile`
Updates current user details and/or avatar.
- **Auth**: Required (`Bearer <token>`)
- **Content-Type**: `multipart/form-data`
- **Fields**:
  - `name` (string, optional)
  - `phoneNumber` (string, optional)
  - `avatar` (file binary, optional)
- **Response `200 OK`**: Updated User Model.

---

#### `DELETE /user/account`
Permenantly deletes user account and personal data.
- **Auth**: Required (`Bearer <token>`)
- **Response `200 OK`**:
  ```json
  {
    "success": true,
    "message": "User account permanently deleted"
  }
  ```

---

### 3.2 Cities & Sectors APIs

#### `GET /cities`
Returns all administrative cities/districts (e.g. Surat, Rajkot, Ahmedabad, etc.).
- **Auth**: None
- **Query Params**:
  - `search` (optional string, e.g. `?search=sur`)
  - `state` (optional string, defaults to `Gujarat`)
- **Response `200 OK`**:
  ```json
  {
    "success": true,
    "data": [
      {
        "id": "surat",
        "name": "Surat",
        "state": "Gujarat",
        "imageUrl": "https://images.unsplash.com/photo-1545645648-524cba4655f4?w=600&auto=format&fit=crop&q=80",
        "businessCount": "120+"
      },
      {
        "id": "rajkot",
        "name": "Rajkot",
        "state": "Gujarat",
        "imageUrl": "https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=600&auto=format&fit=crop&q=80",
        "businessCount": "90+"
      }
    ]
  }
  ```

---

#### `GET /cities/:cityId/sectors`
Returns administrative sectors/areas within a selected city.
- **Auth**: None
- **Query Params**: `search` (optional)
- **Response `200 OK`**:
  ```json
  {
    "success": true,
    "data": [
      {
        "id": "sec_1",
        "name": "Sector 1",
        "cityId": "surat",
        "businessCount": "120+ Businesses"
      },
      {
        "id": "sec_2",
        "name": "Sector 2",
        "cityId": "surat",
        "businessCount": "95+ Businesses"
      }
    ]
  }
  ```

---

### 3.3 Categories APIs

#### `GET /categories`
Returns all categories shown on the Home Screen grid and Categories screen.
- **Auth**: None
- **Query Params**: `city` (optional, to filter counts by city)
- **Response `200 OK`**:
  ```json
  {
    "success": true,
    "data": [
      {
        "id": "doctor",
        "name": "Doctors",
        "subtitle": "Find trusted doctors near you",
        "iconUrl": "https://...",
        "colorHex": "#3B82F6",
        "businessCount": "45+"
      },
      {
        "id": "advocates",
        "name": "Advocates",
        "subtitle": "Expert legal advisors",
        "iconUrl": "https://...",
        "colorHex": "#10B981",
        "businessCount": "32+"
      }
    ]
  }
  ```

---

### 3.4 Businesses Listing, Filter & Search APIs

#### `GET /businesses`
The main query endpoint for search, category listing, and sector listing screens.
- **Auth**: Optional (if provided, `isFavorite` will reflect for the authenticated user)
- **Query Params**:
  - `query` (string, optional: search text against name, specialty, address)
  - `category` (string, optional: e.g. `Doctors`, `Hotel`, `all`)
  - `city` (string, optional: e.g. `Surat`, `Ahmedabad`, `all`)
  - `sector` (string, optional: e.g. `Sector 1`)
  - `minRating` (number, optional: e.g. `4.0`)
  - `openOnly` (boolean, optional: `true`/`false`)
  - `latitude` & `longitude` (number, optional: calculates `distance` from user)
  - `page` (integer, default `1`)
  - `limit` (integer, default `20`)
- **Response `200 OK`**:
  ```json
  {
    "success": true,
    "data": [
      {
        "id": "doc_1",
        "name": "Dr. Jignesh Patel",
        "category": "Doctors",
        "specialty": "General Physician",
        "description": "Experienced General Physician...",
        "imageUrl": "https://...",
        "phoneNumber": "+91 98765 43210",
        "whatsappNumber": "+919876543210",
        "email": "dr.jignesh@gmail.com",
        "rating": 4.8,
        "reviewCount": 120,
        "city": "Surat",
        "sector": "Sector 1",
        "address": "123, City Light Road, Surat - 395007",
        "latitude": 21.1702,
        "longitude": 72.8311,
        "distance": "2.3 km",
        "openingTime": "09:00 AM",
        "closingTime": "08:00 PM",
        "isOpen": true,
        "avatarInitials": "JP",
        "specializations": ["General Checkup", "Diabetes"],
        "isFavorite": false
      }
    ],
    "meta": {
      "total": 54,
      "page": 1,
      "limit": 20,
      "totalPages": 3
    }
  }
  ```

---

#### `GET /businesses/:id`
Retrieves full details for a single business including personal and business contact details.
- **Auth**: Optional
- **Response `200 OK`**: Single Business Model JSON.

---

#### `GET /businesses/top-rated`
Quick endpoint for the Home Screen horizontal / top recommendations.
- **Auth**: Optional
- **Query Params**: `city` (string, optional), `limit` (integer, default `10`)
- **Response `200 OK`**: Array of Business Model JSON.

---

### 3.5 Favorites APIs

#### `GET /user/favorites`
Lists businesses bookmarked by the user.
- **Auth**: Required (`Bearer <token>`)
- **Query Params**: `page`, `limit`
- **Response `200 OK`**: Paginated array of Business Model JSON.

---

#### `POST /user/favorites/:businessId`
Adds a business to the user's favorites.
- **Auth**: Required (`Bearer <token>`)
- **Response `200 OK`**:
  ```json
  {
    "success": true,
    "message": "Business added to favorites"
  }
  ```

---

#### `DELETE /user/favorites/:businessId`
Removes a business from the user's favorites.
- **Auth**: Required (`Bearer <token>`)
- **Response `200 OK`**:
  ```json
  {
    "success": true,
    "message": "Business removed from favorites"
  }
  ```

---

### 3.6 Vendor / Owner Business Management APIs ("My Listings")

#### `GET /vendor/listings`
Returns all listings created and owned by the logged-in user.
- **Auth**: Required (`Bearer <token>`)
- **Response `200 OK`**: Array of Business Model JSON.

---

#### `POST /vendor/listings`
Creates a new business listing.
- **Auth**: Required (`Bearer <token>`)
- **Content-Type**: `multipart/form-data`
- **Fields**:
  - `name` (required string)
  - `category` (required string)
  - `specialty` (required string)
  - `description` (required string)
  - `city` (required string)
  - `sector` (required string)
  - `address` (required string)
  - `latitude` (required float)
  - `longitude` (required float)
  - `phoneNumber` (required string)
  - `whatsappNumber` (optional string)
  - `email` (required string)
  - `openingTime` (required string, e.g. "09:00 AM")
  - `closingTime` (required string, e.g. "08:00 PM")
  - `specializations` (JSON array or comma-separated string)
  - `image` (binary file)
- **Response `201 Created`**: Newly created Business Model.

---

#### `PUT /vendor/listings/:id`
Updates an existing listing owned by the user.
- **Auth**: Required (`Bearer <token>`)
- **Content-Type**: `multipart/form-data` or `application/json`
- **Response `200 OK`**: Updated Business Model.

---

#### `DELETE /vendor/listings/:id`
Deletes a business listing owned by the user.
- **Auth**: Required (`Bearer <token>`)
- **Response `200 OK`**:
  ```json
  {
    "success": true,
    "message": "Listing deleted successfully"
  }
  ```

---

### 3.7 Notifications APIs

#### `GET /notifications`
Retrieves in-app notifications for the user.
- **Auth**: Required (`Bearer <token>`)
- **Query Params**: `page`, `limit`
- **Response `200 OK`**:
  ```json
  {
    "success": true,
    "unreadCount": 2,
    "data": [
      {
        "id": "notif_1",
        "title": "New Specialist in Surat!",
        "subtitle": "Dr. Mehul Desai (Cardiologist) is now available for appointments on Ghod Dod Road.",
        "createdAt": "2026-10-05T15:30:00Z",
        "isRead": false
      },
      {
        "id": "notif_2",
        "title": "Exclusive Dining Discount",
        "subtitle": "Enjoy 20% off your next dinner at The Grand Heritage this weekend.",
        "createdAt": "2026-10-05T13:00:00Z",
        "isRead": false
      }
    ]
  }
  ```

---

#### `PATCH /notifications/mark-read`
Marks notifications as read.
- **Auth**: Required (`Bearer <token>`)
- **Request Body**:
  ```json
  {
    "notificationIds": ["all"]
  }
  ```
- **Response `200 OK`**:
  ```json
  {
    "success": true,
    "unreadCount": 0
  }
  ```

---

#### `POST /notifications/device-token`
Registers device FCM push notification token.
- **Auth**: Required (`Bearer <token>`)
- **Request Body**:
  ```json
  {
    "deviceToken": "fcm_token_string_here",
    "platform": "android"
  }
  ```
- **Response `200 OK`**:
  ```json
  {
    "success": true,
    "message": "Device token updated"
  }
  ```

---

### 3.8 Support, FAQ & Legal APIs

#### `GET /support/faqs`
Returns FAQs displayed on the Help & Support screen.
- **Auth**: None
- **Response `200 OK`**:
  ```json
  {
    "success": true,
    "data": [
      {
        "id": 1,
        "question": "How do I call a business or doctor?",
        "answer": "Simply tap the Call button on any card or detail screen. Your phone dialer will open with the number pre-filled."
      },
      {
        "id": 2,
        "question": "How do I get directions to a clinic or store?",
        "answer": "Tap 'Directions' on the detail page or 'Open in Google Maps' on the Location screen to view turn-by-turn routing."
      }
    ]
  }
  ```

---

#### `POST /support/inquiry`
Submits user feedback or support ticket.
- **Auth**: Optional
- **Request Body**:
  ```json
  {
    "name": "Darshan Pambhar",
    "email": "user@example.com",
    "subject": "App feedback",
    "message": "Great app, please add more cities in South Gujarat."
  }
  ```
- **Response `201 Created`**:
  ```json
  {
    "success": true,
    "message": "Your inquiry has been submitted. Ticket #TIC-5849",
    "ticketId": "TIC-5849"
  }
  ```

---

#### `GET /legal/terms-and-privacy`
Returns static or dynamic legal copy.
- **Auth**: None
- **Query Params**: `type` (`terms` or `privacy`)
- **Response `200 OK`**:
  ```json
  {
    "success": true,
    "data": {
      "title": "Terms of Service & Privacy Policy",
      "lastUpdated": "2026-10-01",
      "content": "Markdown or HTML text of the legal policies..."
    }
  }
  ```

---

## 4. HTTP Status Code Guidelines

| Code | Meaning | When to Use |
| :--- | :--- | :--- |
| `200 OK` | Success | Normal queries, successful updates |
| `201 Created` | Created | Successful POST creation (OTP verify signup, add listing) |
| `400 Bad Request` | Validation Error | Missing required fields, invalid email format, expired OTP |
| `401 Unauthorized` | Auth Error | Missing or expired JWT access token |
| `403 Forbidden` | Permission Error | Attempting to update/delete another vendor's listing |
| `404 Not Found` | Not Found | Business, City, or Category ID does not exist |
| `500 Server Error` | Internal Error | Unexpected database/server exception |
