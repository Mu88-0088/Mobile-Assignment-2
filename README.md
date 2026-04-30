# Country Explorer App

## 1. Student Information
- **Name:** Musab Ashik
- **Student ID:** ATE/0319/15

## 2. Track
Track A — Country Explorer App (API: RestCountries)

## 3. App Description
Country Explorer is a Flutter application that allows users to browse, 
search, and explore detailed information about countries around the world. 
It fetches live data from the RestCountries public API and displays flags, 
regions, capitals, populations, languages, currencies, and timezones for 
every country.

## 4. How to Run the App Locally
1. Clone the repository:
   git clone https://github.com/Mu88-0088/Country_Explorer_App.git
3. Navigate to the project folder:
   cd Country_Explorer_App
4. Install dependencies:
   flutter pub get
5. Run the app:
   flutter run
   
**Alternatively:**

1. Clone the repository:
   git clone https://github.com/Mu88-0088/Country_Explorer_App.git
2. Open FlutLab.io in your browser
3. Click "Open Project" and import from GitHub
4. Click the Run button in FlutLab
   
No API key or .env file is required. The RestCountries API is completely free.

## 5. API Endpoints Used
- GET https://restcountries.com/v3.1/all?fields=name,flags,region,subregion,population,capital,cca3
  — Fetches all countries for the home screen list

- GET https://restcountries.com/v3.1/name/{name}
  — Searches countries by name for the search screen

- GET https://restcountries.com/v3.1/alpha/{code}
  — Fetches full country details by ISO code for the detail screen

## 6. Known Limitations and Bugs
- The RestCountries API occasionally returns 502 Bad Gateway errors 
  during high traffic. The Retry button resolves this.
- Pagination is implemented client-side since the API returns all 
  countries in a single response.
- Some countries have missing data fields (e.g. no capital or currency) 
  which display as N/A.
- App requires an active internet connection on first launch. 
  Cached data is available for 5 minutes after initial load.

## Bonus Features Implemented
- Search Debouncing (400ms delay)
- In-memory Caching with 5-minute TTL and Cached badge indicator
- Pagination with Load More button (20 countries per page)
- Dark/Light theme toggle.
