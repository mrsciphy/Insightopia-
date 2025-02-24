![cover](https://github.com/user-attachments/assets/ed269a95-5f41-4887-a1cb-e3c607806785)
![steps](https://github.com/user-attachments/assets/af47f10d-4474-4a33-b9e6-3e96132b3d3d)

# Manufacturing Downtime Analysis
## Overview & Objective
   This project focuses on analyzing and cleaning a dataset related to the productivity of a drinks manufacturing line. The primary goal is to **identify and address the key downtime factors affecting productivity in August and September 2024, with the aim of reducing manufacturing downtime by at least 20%**.\
To achieve this objective, we will explore the following:

- How does batch processing time compare to the minimum batch time for each product?
- What are the most common downtime factors?
- What is the total production time per operator?
- Which operators have the highest and lowest downtime incidents?
- What is the overall efficiency of the manufacturing line (productive time vs. downtime)?\
![overview](https://github.com/user-attachments/assets/d5d995de-c96d-451d-af89-39b40a927a29)

## Team Members:
* Mohamed Abdelghaffar (Team Lead)
* Madonna Wadeaa
* Yasser Mabrouk
* Saif Tarek
## The scope of the project:
### In-scope: 
+ clean, preprocess and build a data model for the dataset.
+ Determine all the possible analysis and forecast questions to be answered.
+ Analyse the downtime keys/factors and predict the downtime in the next period.
+ Highlight the number of batches to be produced after predicting the downtime.
+ Build a dashboard to visualize the answers of the questions. 
+ Prepare a report summarizing the work of the project.
### Out-of-scope: 
+ Real time monitoring the system of manufacturing.
+ Changes the workflow or scheduling of production.
### Roles of Data analyst Team members:
+ The leader: Mohamed Abdelghaffar.
+ Data governors: 
      **Mohamed Abdelghaffar**:
         * Follow up the procedures of the project plan.
         * Preprocess the dataset and prepare the analysis questions. 
     **Madonna Wadeaa**:
         * Clean the data and handle the missing or null value in the dataset.
         * Answer the analysis questions using SQL.
+ Data storyteller: 
      **Yasser Mabrouk** :
         * Answer the analysis questions using Python.
         * Prepare the dashboard using PowerBi.
      **Saif Tarek**: 
         * Answer the analysis questions using Python.
         * prepare the forecasting questions
### Deliverables: 
+ Cleaned dataset ready for analysis.
+ Preprocessing notebook.
+ Set of analysis and forecasting questions.
+ Visualization dashboard for answering the questions.
+ Final report and presentation.
## Project Plan
### Key Milestones: 
![plan](https://github.com/user-attachments/assets/a3615b06-592d-48c9-bdeb-d808f0738281)

### Project Timeline (Gantt Chart):
![Gantt Chart](https://github.com/user-attachments/assets/05d4b023-f01b-499f-91da-99680e542d1a)

# Risk Assessment and Mitigation Plan
Potential risks that could impact on the success of the analysis and its implementation:\
1. Data collection issues:
   * Risk: incomplete data or too many missing values in the dataset.
   * Impact: poor analysis leading to incorrect downtime cause identification.
   * Mitigation: validate, clean and preprocess the data before the analysis.
2. Analysis challenges:
   * Risk: incorrect statistical and data model leading to misleading conclusions. 
   * Impact: ineffective decision making and wasted time.
   * Mitigation: use multiple analysis tools (SQL, python, Power BI) and continuously refine models with the instructor reflection. 
3. Lack of actionable insights:
   * Risk: analysis results are too complex or do not translate into clear improvements.
   * Impact: difficulty in implementing recommendations leading to no improvements in downtime
   * Mitigation: present the findings in a clear visual dashboard (e.g. charts) and provide actionable recommendations.
4. Lack of meeting time:
   * Risk: team members have their work hours or it’s hard to agree on specific time for all members.
   * Impact: delay in following the project plan procedures leading to poor willingness to work.
   * Mitigation: schedule online meetings via MS. Teams and send the instructions on WhatsApp group of the team. 

## Risk Assessment Matrix:
![risk](https://github.com/user-attachments/assets/021ee1f3-ab3d-45c8-a210-fb0e34bedfcd)

# Key performance indicators (KPIs)
## Production Efficiency KPIs
1.	Total Production Time (hours) – Sum of all batch production times.
2.	Average Cycle Time (minutes per batch) – Average time taken to complete one batch.
3.	Production Throughput (batches per shift/day) – Number of batches produced per shift or day.
4.	Operator Efficiency (%) – Production output per operator per shift.

## Downtime Analysis KPIs
5.	Total Downtime (minutes/hours per day) – Sum of all downtime across batches.
6.	Mean Downtime per Batch (minutes) – Average downtime per production batch.
7.	Downtime as % of Production Time (%) – Ratio of downtime to total available production time.
8.	Top Downtime Causes (%) – Percentage contribution of different downtime factors.

# Requirement Gathering
## Stakeholder’s analysis:
   is a process of identifying people responsible for the project of the manufacturing line; grouping them according to their levels of participation, interest, and influence in the project; and determining how best the insights of the analysis impact on each of these stakeholders.
## Introduction:
**The purpose of the analysis*:
* to enlist the help of key organizational players.
* To gain early alignment among all stakeholders on goals and plans.
* Proactively address potential conflicts or concerns to mitigate risks and improve collaboration.

## Overview of the stakeholders:
![stakeholders2](https://github.com/user-attachments/assets/73f2313d-af1c-4e36-83cc-68e912a9c8f4)
![Picture1](https://github.com/user-attachments/assets/7690a8b1-3395-4de1-b371-620169c3159c)

## Stakeholders’ needs and expectations:
![needs](https://github.com/user-attachments/assets/58d6f952-3d7d-4562-bffa-ba0ad73063cd)

## Impacts of findings on stakeholders:
![needs](https://github.com/user-attachments/assets/18903fd5-d800-4390-9fe7-64839a6c41a1)

![needs](https://github.com/user-attachments/assets/08ad0b95-760a-4a4d-bf43-742413e90260)

# System Analysis & Design
## Overview schema (Tables and attributes):
The problem is to find the downtime keys and try to reduce them by 20%, in the following lines the tables and their attributes of the dataset. 
* Before modification:
![erd1](https://github.com/user-attachments/assets/5ad80c29-87ac-44a6-87db-a863373b3907)

We found that the table of “line downtime” is not structured very well because it has empty cells as shown: 
![table](https://github.com/user-attachments/assets/2c3b543b-d1b6-47c4-bcfa-76195eadcfbd)

So, we had to modify this table into a structured one in order to prepare it for the analysis.
![table2](https://github.com/user-attachments/assets/73303b08-710d-4b7f-9635-9b8491fb5455)

# Overview of schema after modification:
![schema](https://github.com/user-attachments/assets/ac6c7ee9-3b42-42af-a6c5-cbf2dccce4ab)

## Database design & Data modeling:
**ERD (after modification)**:
![erd2](https://github.com/user-attachments/assets/9369e57b-b7f4-4ace-a4b3-fab5b18e9ba9)

**Data Model (Galaxy Schema)**:
![schema2](https://github.com/user-attachments/assets/82bebd79-09ae-4e65-9112-020e2c4019de)

**Data model (from SQL)**: 
![data model](https://github.com/user-attachments/assets/99454f1c-1278-4279-8016-03f7d210a08a)













