# Global Layoffs SQL Cleaning Project

## 📊 Dataset Details
This dataset was collected in 2023 and contains information about global company layoffs. It includes attributes such as company name, location, industry, total laid off, percentage laid off, date, country, and funds raised. The dataset was messy in its raw form, with duplicates, inconsistent values, blanks vs NULLs, and unstructured dates.

## 🛠️ Project Overview
My main task was to clean and standardize the raw layoff data to prepare it for analysis.  
Key steps included:
- Creating a staging table for safe transformations  
- Removing duplicates using `ROW_NUMBER()`  
- Standardizing values (e.g., “CryptoCurrency” → “Crypto”)  
- Handling blanks vs NULLs in industry  
- Converting text dates into proper `DATE` format  
- Removing irrelevant records (no layoff data)  
- Dropping helper columns used during cleaning  

## 💡 SQL Skills Used
- Table creation & staging setup  
- Window functions (`ROW_NUMBER`) for duplicate detection  
- Data manipulation (`UPDATE`, `DELETE`)  
- Data type conversion (`TEXT` → `DATE`)  
- Handling missing values (blanks vs NULLs)  
- Normalization of categorical values  
- Self‑joins for filling missing industries  

## ⚠️ Errors Encountered
1. Tried deleting duplicates directly from a CTE → fixed by creating a staging table.  
2. `date` column stored as `TEXT` → converted to proper `DATE`.  
3. Blank strings (`''`) in industry not updating → converted to `NULL` first.  
4. Companies with only one record and missing industry → left as `NULL`.  
5. Records with no layoff data (`total_laid_off` and `percentage_laid_off` both NULL) → deleted.  
6. Dropped `row_num` column after duplicate detection.  

## 📂 Final Results
- The cleaned dataset is saved as:  
  `Global_Layoffs/data/layoffs_cleaned.csv`

### Sample Preview
| company   | location | industry | total_laid_off | percentage_laid_off | date       | country       |
|-----------|----------|----------|----------------|---------------------|------------|---------------|
| Google    | USA      | Tech     | 1200           | 10%                 | 2023-05-12 | United States |
| Coinbase  | USA      | Crypto   | 200            | 15%                 | 2022-11-01 | United States |
| Infosys   | India    | IT       | 300            | 5%                  | 2023-01-20 | India         |

