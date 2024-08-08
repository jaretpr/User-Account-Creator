# Import the Selenium module
Import-Module Selenium

# Function to create folders for the user
function Create-UserFolders {
    param (
        [string]$username,
        [string]$basePath1 = "C:\Shared\Vol1",  # Change this path if needed
        [string]$basePath2 = "C:\Shared\Vol2\USERSCAN"  # Change this path if needed
    )

    try {
        $folderPath1 = Join-Path -Path $basePath1 -ChildPath $username
        $folderPath2 = Join-Path -Path $basePath2 -ChildPath $username

        if (-not (Test-Path -Path $folderPath1)) {
            New-Item -Path $folderPath1 -ItemType Directory | Out-Null
        }

        if (-not (Test-Path -Path $folderPath2)) {
            New-Item -Path $folderPath2 -ItemType Directory | Out-Null
        }

        return "Folders created successfully for $username."
    } catch {
        $errorMessage = $_.Exception.Message
        return "Error creating folders for " + $username + ": " + $errorMessage
    }
}

# Function to create AD user by copying an existing user
function Create-ADUser {
    param (
        [string]$firstName,
        [string]$lastName,
        [string]$templateUser = "Template User",  # Change to the appropriate template username
        [string]$password = "Password1",  # Change to a secure password
        [string]$ouPath = "OU=General Employees,OU=Users,DC=example,DC=com",  # Change to the appropriate OU path
        [string]$domain = "example.com"  # Change to your domain
    )

    try {
        $username = "$firstName$($lastName.Substring(0,1))"
        $displayName = "$firstName $($lastName.Substring(0,1))"
        $email = "$username@$domain"
        $proxyAddresses = @("SIP:$email","SMTP:$email")

        # Validate OU path
        $ouExists = Get-ADOrganizationalUnit -Filter {DistinguishedName -eq $ouPath} -ErrorAction SilentlyContinue
        if (-not $ouExists) {
            throw "The specified OU path '$ouPath' does not exist."
        }

        # Copy user from template
        $templateUserObject = Get-ADUser -Filter "Name -eq '$templateUser'"
        if (-not $templateUserObject) {
            throw "The template user '$templateUser' does not exist."
        }

        # Create the AD user
        New-ADUser -Name "$firstName $lastName" -GivenName $firstName -Surname $lastName -SamAccountName $username -UserPrincipalName "$username@$domain" -Path $ouPath -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -Enabled $true -ChangePasswordAtLogon $true
        Set-ADUser -Identity $username -DisplayName $displayName -EmailAddress $email -Add @{proxyAddresses=$proxyAddresses}

        return @{
            Status = "User $username created and configured successfully."
            Username = $username
            Email = $email
            FirstName = $firstName
            LastName = $lastName
        }
    } catch {
        $errorMessage = $_.Exception.Message
        return @{
            Status = "Error: " + $errorMessage
            Username = $null
            Email = $null
            FirstName = $null
            LastName = $null
        }
    }
}

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "User Account Creator"
$form.Size = New-Object System.Drawing.Size(600, 400)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)

# Create a label for the title
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "User Account Creator"
$titleLabel.ForeColor = [System.Drawing.Color]::White
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$titleLabel.AutoSize = $true
$titleLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$form.Controls.Add($titleLabel)

# Force layout update to get the correct width
$form.PerformLayout()
$titleLabel.Width = [int]$titleLabel.PreferredWidth

# Center the title label
$titleLabel.Location = New-Object System.Drawing.Point([int](($form.ClientSize.Width - $titleLabel.Width) / 2), 20)

# Create text boxes for user input
$firstNameLabel = New-Object System.Windows.Forms.Label
$firstNameLabel.Text = "First Name:"
$firstNameLabel.ForeColor = [System.Drawing.Color]::White
$firstNameLabel.AutoSize = $true
$form.Controls.Add($firstNameLabel)

$firstNameTextBox = New-Object System.Windows.Forms.TextBox
$form.Controls.Add($firstNameTextBox)

$lastNameLabel = New-Object System.Windows.Forms.Label
$lastNameLabel.Text = "Last Name:"
$lastNameLabel.ForeColor = [System.Drawing.Color]::White
$lastNameLabel.AutoSize = $true
$form.Controls.Add($lastNameLabel)

$lastNameTextBox = New-Object System.Windows.Forms.TextBox
$form.Controls.Add($lastNameTextBox)

# Force layout update to get the correct widths
$form.PerformLayout()

# Calculate the center position for the textboxes
$centerX = [int](($form.ClientSize.Width - $firstNameTextBox.Width) / 2)

# Set locations for labels and textboxes
$firstNameTextBox.Location = New-Object System.Drawing.Point($centerX, 75)
$firstNameLabel.Location = New-Object System.Drawing.Point([int]($firstNameTextBox.Location.X - $firstNameLabel.Width - 10), 80)

$lastNameTextBox.Location = New-Object System.Drawing.Point($centerX, 115)
$lastNameLabel.Location = New-Object System.Drawing.Point([int]($lastNameTextBox.Location.X - $lastNameLabel.Width - 10), 120)

# Create a button to trigger user creation
$createButton = New-Object System.Windows.Forms.Button
$createButton.Text = "Create User"
$createButton.AutoSize = $true
$createButton.BackColor = [System.Drawing.Color]::FromArgb(28, 151, 234)
$createButton.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($createButton)

# Force layout update to get the correct width
$form.PerformLayout()
$createButton.Width = [int]$createButton.PreferredWidth

# Center the button horizontally
$createButton.Location = New-Object System.Drawing.Point([int](($form.ClientSize.Width - $createButton.Width) / 2), 160)

# Create a textbox for log output
$logTextBox = New-Object System.Windows.Forms.TextBox
$logTextBox.Location = New-Object System.Drawing.Point(50, 200)
$logTextBox.Size = New-Object System.Drawing.Size(500, 150)
$logTextBox.Multiline = $true
$logTextBox.ScrollBars = "Vertical"
$logTextBox.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$logTextBox.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($logTextBox)

# Event handler for the create button click event
$createButton.Add_Click({
    $firstName = $firstNameTextBox.Text
    $lastName = $lastNameTextBox.Text

    if ([string]::IsNullOrWhiteSpace($firstName) -or [string]::IsNullOrWhiteSpace($lastName)) {
        $logTextBox.AppendText("First name and last name are required.`r`n")
    } else {
        $logTextBox.AppendText("Creating AD user...`r`n")
        $adResult = Create-ADUser -firstName $firstName -lastName $lastName
        $logTextBox.AppendText($adResult.Status + "`r`n")

        if ($adResult.Status -like "User*created and configured successfully.") {
            $logTextBox.AppendText("Creating folders...`r`n")
            $folderResult = Create-UserFolders -username $adResult.Username
            $logTextBox.AppendText($folderResult + "`r`n")

            $logTextBox.AppendText("Creating KnowBe4 user...`r`n")
            try {
                # Start a new Chrome session
                $options = New-Object OpenQA.Selenium.Chrome.ChromeOptions
                $chromeDriverPath = "C:\Tools\ChromeDriver\chromedriver" # Path to ChromeDriver directory

                $driver = New-Object OpenQA.Selenium.Chrome.ChromeDriver($chromeDriverPath, $options)
                
                # Maximize the browser window
                $driver.Manage().Window.Maximize()

                # Log into KnowBe4
                $driver.Navigate().GoToUrl("https://training.knowbe4.com/ui/login")
                Start-Sleep -Seconds 5

                $driver.FindElementById("email").SendKeys("your-email@example.com") # Replace with your email
                $driver.FindElementByXPath("//button[@qa-id='submit']").Click()
                Start-Sleep -Seconds 5
                $driver.FindElementById("password").SendKeys("YourPassword") # Replace with your password
                $driver.FindElementByXPath("//button[@qa-id='submit']").Click()
                Start-Sleep -Seconds 20

                $driver.FindElementByCssSelector("li#navbar-users.nav-item.nav-item-progressive a.nav-link").Click()
                Start-Sleep -Seconds 5

                $driver.FindElementById("USERS-PAGE-ADD_USERS-DROPDOWN-toggle").Click()
                Start-Sleep -Seconds 5
                $driver.FindElementById("USERS-PAGE-ADD_USERS-DROPDOWN-CREATE_SINGLE_USER").Click()
                Start-Sleep -Seconds 5

                $driver.FindElementById("USER_FORM-EMAIL_INPUT").SendKeys($adResult.Email)
                $driver.FindElementById("USER_FORM-FIRST_NAME_INPUT").SendKeys($adResult.FirstName)
                $driver.FindElementById("USER_FORM-LAST_NAME_INPUT").SendKeys($adResult.LastName)

                # Interacting with the checkbox
                $checkbox = $driver.FindElementById("USER_FORM-GROUPS_CHECKBOX")
                if (-not $checkbox.Selected) {
                    $checkbox.Click()
                }
                
                # Interacting with the dropdown
                $dropdownIndicator = $driver.FindElementByCssSelector(".indicators.svelte-17d7869")
                $dropdownIndicator.Click()
                Start-Sleep -Seconds 5
                
                # Typing "New Hires" and pressing Enter
				# Replace "New Hires" with necessary group name
                $driver.FindElementById("USER_FORM-GROUPS_SELECT").SendKeys("New Hires")
                Start-Sleep -Seconds 2
                $driver.FindElementById("USER_FORM-GROUPS_SELECT").SendKeys([OpenQA.Selenium.Keys]::Enter)
                Start-Sleep -Seconds 5

                $driver.FindElementById("USER_FORM-CREATE_BUTTON").Click()
                Start-Sleep -Seconds 5

                $logTextBox.AppendText("KnowBe4 user created successfully.`r`n")
                $driver.Quit()
            } catch {
                $logTextBox.AppendText("Error creating KnowBe4 user: $_.`r`n")
            }
        }
    }
})

# Show the form
[void]$form.ShowDialog()
