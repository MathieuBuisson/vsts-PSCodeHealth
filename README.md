# PSCodeHealth VSTS Extension  

## Overview  

It is a VSTS extension providing a Build/Release task to gather **PowerShell** code quality metrics.  
This task also allows to define (and optionally enforce) quality gates based on these code metrics.  
It is essentially a wrapper around the **[PSCodeHealth](https://github.com/MathieuBuisson/PSCodeHealth)** PowerShell module to make it easy to use within VSTS.  

## Getting Started  

### Installation  

Get it for free, from the **[Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=MathieuBuisson.MB-PSCodeHealth-task)**.  

### Usage  

Once installed in your VSTS account, the **PSCodeHealth** task will be available for :  
  - Build definitions  
  - Release definitions  

For usage instructions, please refer to the extension's [README](https://github.com/MathieuBuisson/vsts-PSCodeHealth/blob/master/PSCodeHealth/README.md).  

Also, to get a better understanding of what this task can do and how to use it, it is helpful to know the **PSCodeHealth** PowerShell module, which provides all functionality under the hood.  
The following **PSCodeHealth** documentation pages are particularly relevant to the VSTS task usage :  
  - [Code metrics collected by PSCodeHealth](http://pscodehealth.readthedocs.io/en/latest/Metrics/#metrics-collected-for-the-overall-health-report)  
  - [Using PSCodeHealth to check if your code meets metrics goals](http://pscodehealth.readthedocs.io/en/latest/HowDoI/CheckCodeCompliance/)  
  - [Customizing PSCodeHealth's compliance rules according to your metrics goals (quality gate)](http://pscodehealth.readthedocs.io/en/latest/HowDoI/CustomizeComplianceRules/)  

## Contributing to vsts-PSCodeHealth  

You are welcome to contribute to this project. There are many ways you can help :

1. Submit a [bug report](https://github.com/MathieuBuisson/vsts-PSCodeHealth/issues/new?template=bug_report.md).  
2. Submit a fix for an issue.  
3. Submit a [feature request](https://github.com/MathieuBuisson/vsts-PSCodeHealth/issues/new?template=feature_request.md).  
4. Submit test cases.  
5. Tell others about the project.  
6. Tell the developers how much you appreciate the project !  
7. Rate the extension on the [Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=MathieuBuisson.MB-PSCodeHealth-task).  

For more information on how to contribute to **vsts-PSCodeHealth**, please refer to the [contributing guidelines](https://github.com/MathieuBuisson/vsts-PSCodeHealth/blob/master/.github/CONTRIBUTING.md)  
