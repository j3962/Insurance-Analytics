create database Insurance_Analytics;

create schema Insurance_Analytics.bronze_layer;


CREATE OR REPLACE STORAGE INTEGRATION s3_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = '|'
  STORAGE_ALLOWED_LOCATIONS = ('s3://health-insurance-analytics');

Desc integration s3_integration;

CREATE OR REPLACE FILE FORMAT insurance_analytics_file_format
  TYPE = 'CSV'
  FIELD_DELIMITER = '|'
  SKIP_HEADER = 1
  NULL_IF = ('NULL', 'null');

CREATE STAGE S3Stage
url = 's3://health-insurance-analytics'
storage_integration = s3_integration
file_format = insurance_analytics_file_format;

DESC STAGE S3Stage;

list @S3Stage;

use INSURANCE_ANALYTICS.BRONZE_LAYER;

CREATE TABLE State_Rating_Area (
    State STRING ,
    Rating_Area_Id INTEGER ,
    Market STRING ,
    County STRING ,
    MSA STRING ,
    Three_Digit_Zip STRING,
    FIPS STRING  
);

COPY INTO state_rating_area
FROM @S3Stage
FILES = ('RBIS.STATE_RATING_AREA_20230809131114.dat'); 

CREATE TABLE health_insurance_plans (
    HIOS_Plan_ID STRING,
    Plan_Marketing_Name STRING,
    HIOS_Product_ID STRING,
    Market_Coverage STRING,
    Dental_Only_Plan STRING,
    Network_ID STRING,
    Service_Area_ID STRING,
    Formulary_ID STRING,
    New_Existing_Plan STRING,
    Plan_Type STRING,
    Level_of_Coverage STRING,
    Unique_Plan_Design STRING,
    QHP_Non_QHP STRING,
    Notice_Required_for_Pregnancy STRING,
    Plan_Level_Exclusions STRING,
    Cost_Sharing_Plan_Variation_Payment FLOAT,
    Child_Only_Offering STRING,
    Child_Only_Plan_ID STRING,
    Wellness_Program_Offered STRING,
    Disease_Management_Programs_Offered STRING,
    EHB_Apportionment_for_Pediatric_Dental STRING,
    Guaranteed_vs_Estimated_Rate STRING,
    Plan_Effective_Date DATE,
    Plan_Expiration_Date DATE,
    Out_of_Country_Coverage STRING,
    Out_of_Country_Coverage_Description STRING,
    Out_of_Service_Area_Coverage STRING,
    Out_of_Service_Area_Coverage_Description STRING,
    National_Network STRING,
    Enrollment_Payment_URL STRING,
    Life_Cycle_Status_Name STRING,
    EHB_Percent_of_Total_Premium FLOAT,
    Does_this_plan_offer_Composite_Rating STRING,
    Design_Type STRING,
    Plan_Published_Indicator STRING
);

COPY INTO health_insurance_plans
FROM @S3Stage
FILES = ('RBIS.INSURANCE_PLAN_20230809131114.dat'); 


CREATE TABLE insurance_rates (
Plan_ID STRING,
Rate_Effective_Date DATE,
Rate_Expiration_Date DATE,
Age STRING,
Tobacco STRING,
Rating_Area_ID STRING,
Individual_Rate FLOAT,
Individual_Tobacco_Rate FLOAT,
Couple FLOAT,
Primary_Subscriber_and_One_Dependent FLOAT,
Primary_Subscriber_and_Two_Dependents FLOAT,
Primary_Subscriber_and_Three_Dependents FLOAT,
Couple_and_One_Dependent FLOAT,
Couple_and_Two_Dependents FLOAT,
Couple_and_Three_Dependents FLOAT,
HIOS_Issuer_ID STRING,
Market_Coverage STRING
);

COPY INTO insurance_rates
FROM @S3Stage
PATTERN='.*RBIS\.INSURANCE_PLAN_BASE_RATE_FILE.*\.dat';

CREATE TABLE insurance_benefits (
    HIOS_Plan_ID STRING,
    Benefit STRING,
    EHB STRING,
    Benefit_Covered STRING,
    Quantitative_Limit STRING,
    Limit_Quantity INTEGER,
    Limit_Unit STRING,
    Exclusions STRING,
    Explanation STRING,
    EHB_Variance_Reason STRING,
    Excluded_from_In_Network_MOOP STRING,
    Excluded_from_Out_Of_Network_MOOP STRING
);
COPY INTO insurance_benefits
FROM @S3Stage
FILES = ('RBIS.INSURANCE_PLAN_BENEFITS_20230809131114.dat'); 


CREATE TABLE insurance_cost_sharing_details (
    HIOS_Plan_ID STRING,
    CSR_Variation_Type STRING,
    Benefit STRING,
    Multiple_In_Network_Tiers STRING,
    Network_Type STRING,
    Co_payment STRING,
    Co_Insurance STRING,
    Multiple_In_Network_Tiers_Code STRING
);

COPY INTO insurance_cost_sharing_details
FROM @S3Stage
FILES = ('RBIS.INSURANCE_PLAN_BENEFIT_COST_SHARE_20230809131114.dat');

CREATE TABLE service_area_details (
    HIOS_Issuer_ID STRING,
    Service_Area_ID STRING,
    Service_Area_Name STRING,
    State STRING,
    County_Name STRING,
    Partial_County STRING,
    Service_Area_Zip_Code STRING,
    Partial_County_Justification STRING,
    Market STRING
);

    COPY INTO service_area_details
FROM @S3Stage
FILES = ('RBIS.ISSUER_SERVICE_AREA_20230809131114.dat');


CREATE TABLE issuer_business_rules (
    HIOS_Issuer_ID STRING,
    Market STRING,
    Product_ID STRING,
    Plan_ID_Standard_Component STRING,
    Maximum_Underage_Dependents STRING, 
    Maximum_Age_For_Dependents STRING,          
    Age_Determination_Method STRING,
    Tobacco_Status_Determination STRING,
    Allowed_Relationships STRING
);

COPY INTO issuer_business_rules
FROM @S3Stage
FILES = ('RBIS.ISSUER_BUSINESS_RULE_20230809131114.dat');


CREATE TABLE issuer_details (
    HIOS_ISSUER_ID STRING,
    ISSR_LGL_NAME STRING,
    Marketing_Name STRING,
    State STRING,
    Individual_Market STRING,
    Small_Group_Market STRING,
    Unknown_Market STRING,
    Large_Market STRING,
    FEDERAL_EIN STRING,
    Active STRING,
    Date_Created DATE,
    Last_Modified_Date DATE,
    Database_Company_ID STRING,
    ORG_ADR1 STRING,
    ORG_ADR2 STRING,
    ORG_CITY STRING,
    ORG_STATE STRING,
    ORG_ZIP STRING,
    ORG_ZIP4 STRING
);

list @s3stage;
COPY INTO issuer_details
FROM @S3Stage
FILES = ('Issuer_Details.txt');

CREATE TABLE product_details (
    HIOS_Product_ID STRING,
    HIOS_Issuer_ID STRING,
    Product_Name STRING,
    Product_Type STRING,
    Market_Type STRING,
    Open_For_Enrollment STRING,
    Association_Product STRING,
    Grandfathered_Product STRING,
    Approved STRING,
    Active STRING,
    CreatedDate DATE,
    ModifiedDate DATE
);
list @s3stage;
    COPY INTO product_details
FROM @S3Stage
FILES = ('Products.txt');
select * from product_details;