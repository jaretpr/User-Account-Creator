# User Account Creator

## Description
This PowerShell script creates a graphical user interface (GUI) for creating user accounts in Active Directory, creating necessary user folders, and adding the user to KnowBe4 for training purposes. The script uses Selenium for automating the KnowBe4 user creation process.

## Features
- GUI for user interaction
- Create user accounts in Active Directory
- Create user folders on specified paths
- Automate the creation of KnowBe4 user accounts using Selenium

## Prerequisites
- Windows operating system
- PowerShell installed
- Active Directory module for PowerShell
- Selenium PowerShell module
- ChromeDriver installed and added to your system's PATH
- Necessary permissions to create users in Active Directory and folders on the file system
- KnowBe4 account credentials for automation

## Setup Instructions
1. **Install Required Modules:**
   - Install the Active Directory module:
     ```powershell
     Install-WindowsFeature -Name RSAT-AD-PowerShell
     ```
   - Install the Selenium module:
     ```powershell
     Install-Module -Name Selenium
     ```

2. **Download and Install ChromeDriver:**
   - Download ChromeDriver from [ChromeDriver Downloads](https://sites.google.com/a/chromium.org/chromedriver/downloads).
   - Extract the downloaded file and place it in a directory.
   - Add the directory to your system's PATH.

3. **Place the Script:**
   - Place the `UserAccountCreator.ps1` script in your desired directory.

4. **Modify the Script:**
   - Update the paths, template username, passwords, and email addresses in the script as indicated by the comments.

## Usage Instructions
1. **Open PowerShell with Administrative Privileges:**
   - Right-click on the PowerShell icon and select `Run as administrator`.

2. **Navigate to the Script Directory:**
   ```powershell
   cd path\to\your\script

3. **Run the Script**
   ```powershell
   .\UserAccountCreator.ps1

4. **Interact with the GUI**
   - **First Name and Last Name:** Enter the first name and last name of the user
   - **Create User:** Click the "Create User" button to create the user account in Active Directory, create necessary folders, and add the user to KnowBe4.

## Script Details
- **Create-UserFolders Function:**
- Creates user folders in specified paths.
- Modify the paths in the script as necessary.
- **Create-ADUser Function:**
- Creates a new Active Directory user by copying attributes from a template user.
- Modify the template username, OU path, domain, and password in the script as necessary.
- **Selenium Automation:**
- Automates the process of creating a KnowBe4 user.
- Update the email and password for logging into KnowBe4 in the script.

## Example Changes
- **Paths:**
  ```powershell
  $basePath1 = "C:\Shared\Vol1"  # Change this path if needed
  $basePath2 = "C:\Shared\Vol2\USERSCAN"  # Change this path if needed
  $chromeDriverPath = "C:\Tools\ChromeDriver\chromedriver"  # Path to ChromeDriver directory
- **Template User:**
  ```powershell
  $templateUser = "Template User"  # Change to the appropriate template username
- **Paswords:**
  ```powershell
  $password = "Password1"  # Change to a secure password
- **Email:**
  ```powershell
  $driver.FindElementById("email").SendKeys("your-email@example.com")  # Replace with your email
  $driver.FindElementById("password").SendKeys("YourPassword")  # Replace with your password
- **Group:**
  ```powershell
   $driver.FindElementById("USER_FORM-GROUPS_SELECT").SendKeys("New Hires") # Replace with your group name
  
