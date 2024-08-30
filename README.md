# Use MATLAB with CircleCI

This orb provides commands to build and test MATLAB and Simulink projects on CircleCI.

## Usage

Learn how to use this MATLAB orb on the [CircleCI Orb Registry](https://circleci.com/orbs/registry/orb/mathworks/matlab).



This orb enables you to build and test your MATLAB&reg; project as part of your pipeline. For example, you can automatically identify any code issues in your project, run tests and generate test and coverage artifacts, and package your files into a toolbox.

To run your pipeline using this orb, [install the extension](https://docs.microsoft.com/en-us/azure/devops/marketplace/install-extension?view=azure-devops&tabs=browser) to your Azure&reg; DevOps organization. To install the extension, click the **Get it free** button at the top of this page. You can use the orb with self-hosted or cloud-hosted [runners](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/agents?view=azure-devops&tabs=browser):

- To use a self-hosted runner, you must set up a computer with MATLAB as your self-hosted runner and register the runner with Azure Pipelines. The runner uses the topmost MATLAB release on the system path to execute your pipeline.
- To use a Microsoft-hosted agent, you must include the [`install`](#install) command in your pipeline to install your preferred MATLAB release on the agent.

## Examples
When you author your pipeline in a file named `azure-pipelines.yml` in the root of your repository, the extension provides you with four different commands:
- To install a specific release of MATLAB on a Microsoft-hosted agent, use the [`install`](#install) command.
- To run a MATLAB build using the MATLAB build tool, use the [`run-build`](#run-build) command.
- To run MATLAB and Simulink&reg; tests and generate artifacts, use the [`run-tests`](#run-tests) command.
- To run MATLAB scripts, functions, and statements, use the [`run-command`](#run-command) command.

### Run a MATLAB Build
On a self-hosted runner, run a MATLAB build task named `mytask`, specified in a build file named `buildfile.m` in the root of your repository, as well as all the tasks on which it depends. To run the MATLAB build, specify the `run-build` command in your pipeline. (The `run-build` command is supported in MATLAB R2022b and later.)

```YAML
pool: myPool
steps:
  - task: RunMATLABBuild@1
    inputs:
      tasks: mytask
``` 

### Generate Test and Coverage Artifacts
Using the latest release of MATLAB on a cloud-hosted agent, run the tests in your [MATLAB project](https://www.mathworks.com/help/matlab/projects.html) and generate test results in PDF and JUnit-style XML formats and code coverage results in Cobertura XML format. Publish the generated artifacts to Azure Pipelines once the test run is complete. To install the latest release of MATLAB on the runner, specify the `install` command in your pipeline. To run the tests and generate the artifacts, specify the `run-tests` command.

```YAML
pool:
  vmImage: ubuntu-latest
steps:
  - task: InstallMATLAB@1
  - task: RunMATLABTests@1
    inputs:
      testResultsPDF: test-results/results.pdf
      testResultsJUnit: test-results/results.xml
      codeCoverageCobertura: code-coverage/coverage.xml
  - task: PublishBuildArtifacts@1
    inputs:
      pathToPublish: test-results/results.pdf
  - task: PublishTestResults@2
    condition: succeededOrFailed()
    inputs:
      testResultsFiles: test-results/results.xml
  - task: PublishCodeCoverageResults@2
    inputs:
      codeCoverageTool: Cobertura
      summaryFileLocation: code-coverage/coverage.xml
``` 

 You can access the artifacts in the pipeline summary window:

- To download the PDF test report, follow the **1 published** link. 
- To view the test results in JUnit-style XML format, open the **Tests** tab.
- To view the code coverage results in Cobertura XML format, open the **Code Coverage** tab.


### Run Tests in Parallel
Run your MATLAB and Simulink tests in parallel (requires Parallel Computing Toolbox&trade;) using the latest release of the required products on a cloud-hosted runner. To install the latest release of MATLAB, Simulink, Simulink Test&trade;, and Parallel Computing Toolbox on the runner, specify the `install` command with its `products` parameter in your pipeline. To run the tests in parallel, specify the `run-tests` command with its `use-parallel` parameter specified as `true`.

```YAML
version: 2.1
orbs:
  matlab: mathworks/matlab@1
jobs:
  my-job:    
    machine:
      image: ubuntu-2204:current
    steps:
      - checkout
      - matlab/install:
          products: >
            Simulink 
            Simulink_Test 
            Parallel_Computing_Toolbox
      - matlab/run-tests:
          use-parallel: true
workflows:
  build:
    jobs:
      - my-job
``` 

### Run MATLAB Script
Run the commands in a file named `myscript.m` in the root of your repository using MATLAB R2023b on a cloud-hosted runner. To install the specified release of MATLAB on the runner, specify the `install` command with its `release` parameter in your pipeline. To run the script, specify the `run-command` command.

```YAML
pool:
  vmImage: ubuntu-latest
steps:
  - task: InstallMATLAB@1
    inputs:
      release: R2023b
  - task: RunMATLABCommand@1
    inputs:
      command: myscript
```

### Specify MATLAB Release on Self-Hosted Runner
When you use the `run-build`, `run-tests`, or `run-command` command in your pipeline, the runner uses the topmost MATLAB release on the system path. The command fails if the runner cannot find any release of MATLAB on the path.

You can prepend your preferred release of MATLAB to the `PATH` system environment variable of the self-hosted runner. For example, prepend MATLAB R2020b to the path and use it to run a script. The step depends on your operating system and MATLAB root folder.

```YAML
pool: myPool
steps:
  - powershell: Write-Host '##vso[task.prependpath]C:\Program Files\MATLAB\R2020b\bin'  # Windows agent
# - bash: echo '##vso[task.prependpath]/usr/local/MATLAB/R2020b/bin'  # Linux agent
# - bash: echo '##vso[task.prependpath]/Applications/MATLAB_R2020b.app/bin'  # macOS agent
  - task: RunMATLABCommand@1
    inputs:
      command: myscript
```

### Use MATLAB Batch Licensing Token
On a cloud-hosted runner, you need a [MATLAB batch licensing token](https://github.com/mathworks-ref-arch/matlab-dockerfile/blob/main/alternates/non-interactive/MATLAB-BATCH.md#matlab-batch-licensing-token) if your project is private or if your pipeline includes transformation products, such as MATLAB Coder&trade; and MATLAB Compiler&trade;. Batch licensing tokens are strings that enable MATLAB to start in noninteractive environments. You can request a token by submitting the [MATLAB Batch Licensing Pilot](https://www.mathworks.com/support/batch-tokens.html) form. 

To use a MATLAB batch licensing token:

1. Set the token as a secret variable. For more information about secret variables, see [Set secret variables](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/set-secret-variables?view=azure-devops&tabs=yaml%2Cbash).
2. Map the secret variable to an environment variable named `MLM_LICENSE_TOKEN` in each of the `run-build`, `run-tests`, and `run-command` commands of your pipeline. 

For example, use the latest release of MATLAB on a cloud-hosted runner to run the tests in your private project. To install the latest release of MATLAB on the runner, specify the `Install MATLAB` command in your pipeline. To run the tests, specify the `Run MATLAB Tests` command. In this example, `myToken` is the name of the secret variable that holds the batch licensing token.

```YAML
pool:
  vmImage: ubuntu-latest
steps:
- task: InstallMATLAB@1
- task: RunMATLABTests@1
  env:
    MLM_LICENSE_TOKEN: $(myToken)
```

### Build Across Multiple Platforms
The `install` command supports the Linux&reg;, Windows&reg;, and macOS platforms. Use a `matrix` job strategy to run a build using the MATLAB build tool on all the supported platforms. This pipeline runs three jobs.

```YAML
strategy:
  matrix:
    linux:
      imageName: ubuntu-latest
    windows:
      imageName: windows-latest
    mac:
      imageName: macOS-latest
pool:
  vmImage: $(imageName)
steps:
- task: InstallMATLAB@1
- task: RunMATLABBuild@1
  inputs:
    tasks: test
```

## Commands
You can access the orb commands using the YAML pipeline editor in Azure DevOps. 

![tasks](https://github.com/mathworks/matlab-azure-devops-extension/assets/48831250/d48ddb8b-a87f-4334-a301-64293b822647)

### `install`
Use the `install` command to install MATLAB and other MathWorks&reg; products on a cloud-hosted runner. When you specify this command as part of your pipeline, the command installs your preferred MATLAB release (R2021a or later) on a Linux, Windows, or macOS runner and prepends it to the `PATH` system environment variable. If you do not specify a release, the command installs the latest release of MATLAB.

The `install` command accepts optional parameters.

Parameter            | Description 
-------------------- | ------------
`release`            | <p>(Optional) MATLAB release to install. You can specify R2021a or a later release. By default, the value of `release` is `latest`, which corresponds to the latest release of MATLAB.</p><p><ul><li>To install the latest update of a release, specify only the release name, for example, `R2023b`.</li><li>To install a specific update release, specify the release name with an update number suffix, for example, `R2023bU4`.</li><li>To install a release without updates, specify the release name with an update 0 or general release suffix, for example, `R2023bU0` or `R2023bGR`.</li></ul></p><p>**Example**: `release: R2023b`<br/>**Example**: `release: latest`<br/>**Example**: `release: R2023bU4`</p>
`products`           | <p>(Optional) Products to install in addition to MATLAB, specified as a list of product names separated by spaces. You can specify `products` to install most MathWorks products and support packages. The command uses [MATLAB Package Manager](https://github.com/mathworks-ref-arch/matlab-dockerfile/blob/main/MPM.md) (`mpm`) to install products.</p><p>For a list of supported products, open the input file for your preferred release from the [`mpm-input-files`](https://github.com/mathworks-ref-arch/matlab-dockerfile/tree/main/mpm-input-files) folder on GitHub&reg;. Specify products using the format shown in the input file, excluding the `#product.` prefix. For example, to install Deep Learning Toolbox&trade; in addition to MATLAB, specify `products: Deep_Learning_Toolbox`.</p><p>For an example of how to use the `products` parameter, see [Run Tests in Parallel](#run-tests-in-parallel).</p><p>**Example**: `products: Simulink`<br/>**Example:** `products: Simulink Deep_Learning_Toolbox`</p>
`no-output-timeout` | <p>(Optional) Elapsed time the command can run without output, specified as a numeric value suffixed with a time unit. By default, the no-output timeout is 10 minutes (10m). The maximum value is governed by the [maximum time a job is allowed to run](https://circleci.com/docs/configuration-reference/#jobs).</p><p>**Example:** `no-output-timeout: 30s`<br/>**Example:** `no-output-timeout: 5m`<br/>**Example:** `no-output-timeout: 0.5h`</p>

#### Licensing
Product licensing for your pipeline depends on your project visibility as well as the type of products to install:

- Public project — If your pipeline does not include transformation products, such as MATLAB Coder and MATLAB Compiler, then the orb automatically licenses any products that you install. If your pipeline includes transformation products, you can request a [MATLAB batch licensing token](https://github.com/mathworks-ref-arch/matlab-dockerfile/blob/main/alternates/non-interactive/MATLAB-BATCH.md#matlab-batch-licensing-token) by submitting the [MATLAB Batch Licensing Pilot](https://www.mathworks.com/support/batch-tokens.html) form.
- Private project — The orb does not automatically license any products for you. You can request a token by submitting the [MATLAB Batch Licensing Pilot](https://www.mathworks.com/support/batch-tokens.html) form.
  
To use a MATLAB batch licensing token, first set it as a [secret variable](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/set-secret-variables?view=azure-devops&tabs=yaml%2Cbash). Then, map the secret variable to an environment variable named `MLM_LICENSE_TOKEN` in your pipeline. For an example, see [Use MATLAB Batch Licensing Token](#use-matlab-batch-licensing-token). 

>**Note:** The `install` command automatically includes the [MATLAB batch licensing executable](https://github.com/mathworks-ref-arch/matlab-dockerfile/blob/main/alternates/non-interactive/MATLAB-BATCH.md) (`matlab-batch`). To use a MATLAB batch licensing token in a pipeline that does not use this command, you must first download the executable and add it to the system path.

### `run-build`
Use the `run-build` command to run a build using the MATLAB build tool. Starting in R2022b, you can use this command to run the MATLAB build tasks specified in a build file. By default, the `run-build` command looks for a build file named `buildfile.m` in the root of your repository. For more information about the build tool, see [Overview of MATLAB Build Tool](https://www.mathworks.com/help/matlab/matlab_prog/overview-of-matlab-build-tool.html).

The `run-build` command accepts optional parameters.

Parameter                | Description
-------------------------| ---------------
`tasks`                  | <p>(Optional) MATLAB build tasks to run, specified as a list of task names separated by spaces. If a task accepts arguments, enclose them in parentheses. If you do not specify `tasks`, the command runs the default tasks in your build file as well as all the tasks on which they depend.</p><p>MATLAB exits with exit code 0 if the tasks run without error. Otherwise, MATLAB terminates with a nonzero exit code, which causes the command to fail.</p><p>**Example:** `tasks: test`<br/>**Example:** `tasks: compile test`<br/>**Example:** `tasks: check test("myFolder",OutputDetail="concise") archive("source.zip")`</p>
`build-options`          | <p>(Optional) MATLAB build options, specified as a list of options separated by spaces. The command supports the same [options](https://www.mathworks.com/help/matlab/ref/buildtool.html#mw_50c0f35e-93df-4579-963d-f59f2fba1dba) that you can pass to the `buildtool` command.</p><p>**Example:** `build-options: -continueOnFailure`<br/>**Example:** `build-options: -continueOnFailure -skip test`</p>
`startup-options`        | <p>(Optional) MATLAB startup options, specified as a list of options separated by spaces. For more information about startup options, see [Commonly Used Startup Options](https://www.mathworks.com/help/matlab/matlab_env/commonly-used-startup-options.html).</p><p>Using this parameter to specify the `-batch` or `-r` option is not supported.</p><p>**Example:** `startup-options: -nojvm`<br/>**Example:** `startup-options: -nojvm -logfile output.log`</p>
`no-output-timeout`      | <p>(Optional) Elapsed time the command can run without output, specified as a numeric value suffixed with a time unit. By default, the no-output timeout is 10 minutes (10m). The maximum value is governed by the [maximum time a job is allowed to run](https://circleci.com/docs/configuration-reference/#jobs).</p><p>**Example:** `no-output-timeout: 30s`<br/>**Example:** `no-output-timeout: 5m`<br/>**Example:** `no-output-timeout: 0.5h`</p>

### `run-tests`
Use the `run-tests` command to run tests authored using the MATLAB unit testing framework or Simulink Test and generate test and coverage artifacts.

By default, the command includes any files in your project that have a `Test` label. If your pipeline does not use a MATLAB project, or if it uses a MATLAB release before R2019a, then the command includes all tests in the root of your repository and in any of its subfolders. The command fails if any of the included tests fail. 

The `run-tests` command accepts optional parameters.

Parameter                    | Description
---------------------------- | ---------------
`source-folder`              | <p>(Optional) Location of the folder containing source code, specified as a path relative to the project root folder. The specified folder and its subfolders are added to the top of the MATLAB search path. If you specify `source-Folder` and then generate a coverage report, the command uses only the source code in the specified folder and its subfolders to generate the report. You can specify multiple folders using a colon-separated or semicolon-separated list.</p><p>**Example:** `source-folder: source`<br/>**Example:** `source-folder: source/folderA; source/folderB`</p>
`select-by-folder`           | <p>(Optional) Location of the folder used to select test suite elements, specified as a path relative to the project root folder. To create a test suite, the command uses only the tests in the specified folder and its subfolders. You can specify multiple folders using a colon-separated or semicolon-separated list.</p><p>**Example:** `select-by-folder: test`<br/>**Example:** `select-by-folder: test/folderA; test/folderB`</p>
`select-by-tag`              | <p>(Optional) Test tag used to select test suite elements. To create a test suite, the command uses only the test elements with the specified tag.</p><p>**Example:** `select-by-tag: Unit`</p>
`strict`                     | <p>(Optional) Option to apply strict checks when running tests, specified as `false` or `true`. By default, the value is `false`. If you specify a value of `true`, the command generates a qualification failure whenever a test issues a warning.</p><p>**Example:** `strict: true`</p>
`use-parallel`               | <p>(Optional) Option to run tests in parallel, specified as `false` or `true`. By default, the value is `false` and tests run in serial. If the test runner configuration is suited for parallelization, you can specify a value of `true` to run tests in parallel. This parameter requires a Parallel Computing Toolbox license.</p><p>**Example:** `use-parallel: true`</p>
`output-detail`              | <p>(Optional) Amount of event detail displayed for the test run, specified as `none`, `terse`, `concise`, `detailed`, or `verbose`. By default, the command displays failing and logged events at the `detailed` level and test run progress at the `concise` level.<p></p>**Example:** `output-detail: verbose`</p>
`logging-level`              | <p>(Optional) Maximum verbosity level for logged diagnostics included for the test run, specified as `none`, `terse`, `concise`, `detailed`, or `verbose`. By default, the command includes diagnostics logged at the `terse` level.<p></p>**Example:** `logging-level: detailed`</p>
`test-results-html`          | <p>(Optional) Location to write the test results in HTML format, specified as a path relative to the project root folder.</p><p>**Example:** `test-results-html: test-results/results.html`</p>
`test-results-pdf`           | <p>(Optional) Location to write the test results in PDF format, specified as a path relative to the project root folder. On macOS platforms, this parameter is supported in MATLAB R2020b and later.</p><p>**Example:** `test-results-pdf: test-results/results.pdf`</p>
`test-results-junit`         | <p>(Optional) Location to write the test results in JUnit-style XML format, specified as a path relative to the project root folder.</p><p>**Example:** `test-results-junit: test-results/results.xml`</p>
`test-results-simulink-test` | <p>(Optional) Location to export Simulink Test Manager results in MLDATX format, specified as a path relative to the project root folder. This parameter requires a Simulink Test license and is supported in MATLAB R2019a and later.</p><p>**Example:** `test-results-simulink-test: test-results/results.mldatx`</p>
`code-coverage-html`         | <p>(Optional) Location to write the code coverage results in HTML format, specified as a path relative to the project root folder.</p><p>**Example:** `code-coverage-html: code-coverage/coverage.html`</p>
`code-coverage-coberura`     | <p>(Optional) Location to write the code coverage results in Cobertura XML format, specified as a path relative to the project root folder.</p><p>**Example:** `code-coverage-cobertura: code-coverage/coverage.xml`</p>
`model-coverage-html`        | <p>(Optional) Location to write the model coverage results in HTML format, specified as a path relative to the project root folder. This parameter requires a Simulink Coverage&trade; license and is supported in MATLAB R2018b and later.</p><p>**Example:** `model-coverage-html: model-coverage/coverage.html`</p>
`model-coverage-cobertura`   | <p>(Optional) Location to write the model coverage results in Cobertura XML format, specified as a path relative to the project root folder. This parameter requires a Simulink Coverage&trade; license and is supported in MATLAB R2018b and later.</p><p>**Example:** `model-coverage-cobertura: model-coverage/coverage.xml`</p>
`startup-options`            | <p>(Optional) MATLAB startup options, specified as a list of options separated by spaces. For more information about startup options, see [Commonly Used Startup Options](https://www.mathworks.com/help/matlab/matlab_env/commonly-used-startup-options.html).</p><p>Using this parameter to specify the `-batch` or `-r` option is not supported.</p><p>**Example:** `startup-options: -nojvm`<br/>**Example:** `startup-options: -nojvm -logfile output.log`</p>
`no-output-timeout`         | <p>(Optional) Elapsed time the command can run without output, specified as a numeric value suffixed with a time unit. By default, the no-output timeout is 10 minutes (10m). The maximum value is governed by the [maximum time a job is allowed to run](https://circleci.com/docs/configuration-reference/#jobs).</p><p>**Example:** `no-output-timeout: 30s`<br/>**Example:** `no-output-timeout: 5m`<br/>**Example:** `no-output-timeout: 0.5h`</p>

>**Note:** To customize the pretest state of the system, you can specify startup code that automatically executes before your tests run. For information on how to specify startup or shutdown files in a MATLAB project, see [Automate Startup and Shutdown Tasks](https://www.mathworks.com/help/matlab/matlab_prog/automate-startup-and-shutdown-tasks.html). If your pipeline does not use a MATLAB project, specify the commands you want executed at startup in a `startup.m` file instead, and save the file to the root of your repository. See [`startup`](https://www.mathworks.com/help/matlab/ref/startup.html) for more information.

### `run-command`
Use the `run-command` command to run MATLAB scripts, functions, and statements. You can use this command to flexibly customize your test run or add a step in MATLAB to your pipeline. 

The `run-command` command requires a parameter and also accepts optional parameters.

Parameter                 | Description
------------------------- | ---------------
`command`                 | <p>(Required) Script, function, or statement to execute. If the value of `command` is the name of a MATLAB script or function, do not specify the file extension. If you specify more than one script, function, or statement, use a comma or semicolon to separate them.</p><p>MATLAB exits with exit code 0 if the specified script, function, or statement executes successfully without error. Otherwise, MATLAB terminates with a nonzero exit code, which causes the command to fail. To fail the command in certain conditions, use the [`assert`](https://www.mathworks.com/help/matlab/ref/assert.html) or [`error`](https://www.mathworks.com/help/matlab/ref/error.html) function.</p><p>**Example:** `command: myscript`<br/>**Example:** `command: results = runtests, assertSuccess(results);`</p>
`startup-options`         | <p>(Optional) MATLAB startup options, specified as a list of options separated by spaces. For more information about startup options, see [Commonly Used Startup Options](https://www.mathworks.com/help/matlab/matlab_env/commonly-used-startup-options.html).</p><p>Using this parameter to specify the `-batch` or `-r` option is not supported.</p><p>**Example:** `startup-options: -nojvm`<br/>**Example:** `startup-options: -nojvm -logfile output.log`</p>
`no-output-timeout`       | <p>(Optional) Elapsed time the command can run without output, specified as a numeric value suffixed with a time unit. By default, the no-output timeout is 10 minutes (10m). The maximum value is governed by the [maximum time a job is allowed to run](https://circleci.com/docs/configuration-reference/#jobs).</p><p>**Example:** `no-output-timeout: 30s`<br/>**Example:** `no-output-timeout: 5m`<br/>**Example:** `no-output-timeout: 0.5h`</p>

When you use this command, all of the required files must be on the MATLAB search path. If your script or function is not in the root of your repository, you can use the [`addpath`](https://www.mathworks.com/help/matlab/ref/addpath.html), [`cd`](https://www.mathworks.com/help/matlab/ref/cd.html), or [`run`](https://www.mathworks.com/help/matlab/ref/run.html) function to put it on the path. For example, to run `myscript.m` in a folder named `myfolder` located in the root of the repository, you can specify `command` like this:

`command: addpath("myfolder"), myscript`

## Notes
* By default, when you use the `run-build`, `run-tests`, or `run-command` command, the root of your repository serves as the MATLAB startup folder. To run your MATLAB code using a different folder, specify the `-sd` startup option or include the `cd` command when using `run-command`.
* The `run-build` command uses the `-batch` option to invoke the MATLAB build tool. In addition, in MATLAB R2019a and later, the `run-tests` and `run-command` commands use  the `-batch` option to start MATLAB noninteractively. Preferences do not persist across different MATLAB sessions launched with the `-batch` option. To run code that requires the same preferences, use a single command.

## See Also
- [Continuous Integration with MATLAB and Simulink](https://www.mathworks.com/solutions/continuous-integration.html)
- [Continuous Integration with MATLAB on CI Platforms](https://www.mathworks.com/help/matlab/matlab_prog/continuous-integration-with-matlab-on-ci-platforms.html)

## Contact Us
If you have any questions or suggestions, contact MathWorks at [continuous-integration@mathworks.com](mailto:continuous-integration@mathworks.com).
