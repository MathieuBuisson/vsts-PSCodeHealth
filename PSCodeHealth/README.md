## What is PSCodeHealth  

**PSCodeHealth** is a PowerShell module which allows you to measure the quality and maintainability of your PowerShell code, based on a variety of metrics related to :  
  - Code length  
  - Code complexity  
  - Code smells, styling issues and violations of best practices  
  - Tests and test coverage  
  - Comment-based help  

It allows to define quality gates for your PowerShell code, based on these metrics.  
You can override some (or all) of the default compliance rules to fit your code quality goals.  

## About the PSCodeHealth VSTS extension  

This VSTS extension provides a Build/Release task to gather **PowerShell** code quality metrics.  
This task also allows to define (and optionally enforce) quality gates based on these code metrics.  
It is essentially a wrapper around the **[PSCodeHealth](https://github.com/MathieuBuisson/PSCodeHealth)** PowerShell module to make it easy to use within VSTS.  

### Features  

  - Analyse code in PowerShell files (.ps1, .psm1 and .psd1) or a directory  
  - Run [Pester](https://github.com/pester/Pester) tests and summarize results and code coverage information  
  - Generate an HTML report (here is [a live example](https://mathieubuisson.github.io/assets/html/healthreport.html))  
  - Select specific code metrics to evaluate for compliance  
  - Override some (or all) compliance rules with rules defined in a JSON file  
  - Enforce the quality gate, i.e.: fail the build in case of compliance failure(s)  

## Using the PSCodeHealth extension  

### Installation  

  * Browse to the [Visual Studio Team Services marketplace](https://marketplace.visualstudio.com/vsts)  
  * In the search box type : `pscodehealth`  
  * There should be only 1 result, click on it  
  * Click on the "Get it free" button  
  * Select your VSTS account and click "Install"  
  * After a few seconds, you should see a message telling that you are all set and a link to your VSTS account  

Once installed in your VSTS account, the **PSCodeHealth** task will be available for :  
  - Build definitions  
  - Release definitions  

### Using the task in a build definition  

