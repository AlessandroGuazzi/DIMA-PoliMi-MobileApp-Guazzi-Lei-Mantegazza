# Design and Implementation of Mobile Applications' Project

**Creators:** Alessandro Guazzi, Leonardo Lei, Niccolò Mantegazza  

---

## 📌 Application Overview
The **Simply Travel** application is designed to provide users with a complete and interactive travel planning experience.  
It allows registered users to:
- Create, edit, and manage trips by specifying destinations, dates, transportation, accommodations, and planned activities.  
- Track expenses with a detailed breakdown by category.  
- Visualize trips on interactive maps.  
- Share trips publicly with the community and explore itineraries created by other users.  
- Mark favourite trips for inspiration and keep track of achievements through a gamified medal system.  

The application also includes a personal profile with editable information, travel statistics, and achievements, enhancing both personal organization and social interaction.

---

## 📂 Repository Organization
In the repository are present:
- A **folder** with all the code of the project
- A **Design Document** in which all the phases of the project are described in detail
- A **presentation** of the project


---

## ⚙️ Technologies Used
- **Frontend:** Flutter (cross-platform for iOS & Android)  
- **Backend & Services:** Firebase (Authentication, Firestore, Core)  
- **External APIs & Packages:**  
  - Google Places API (location search & autocomplete)  
  - Unsplash API (high-quality images)  
  - Hexarate Currency Exchange API (real-time conversion)  
  - Google Maps (trip map visualization)  
  - Countries World Map (visited countries tracking)  
  - Various Flutter packages: `country_picker`, `intl`, `http`, `flutter_typeahead`, `pie_chart`, `add_2_calendar`, `mockito`, etc.  

The architecture follows a **Model–View–Controller (MVC)** inspired pattern with a clean separation of data, UI, and control logic.

---

## 🧪 Testing Campaign
A thorough testing campaign was carried out to ensure stability and reliability:  
- **Unit Tests:** Focused on models and basic computational logic (e.g., serialization/deserialization).  
- **Widget Tests:** Verified UI rendering and correct behaviour in both smartphone and tablet layouts.  
- **Integration Tests:** Validated complete user flows (authentication, trip creation, editing, expenses, privacy settings, etc.) with real backend services.  
- **Coverage Analysis:**  
  - **197 widget/unit tests** and **24 integration tests**  
  - **92.6% code coverage** over ~4,535 lines  
  - Several UI components achieved **100% coverage**  

---

## 🏆 Final Evaluation
**Grade:** 30L / 30  

---
