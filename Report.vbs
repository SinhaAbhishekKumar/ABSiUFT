

Public Function fnGenerateHTMLTS()

	Dim fso : Set fso = CreateObject("Scripting.FileSystemObject")
	Dim arrWrite, objWrite
	Dim SQL	
	Dim totalTCs, PassTCs, FailTCs
	Dim sHTMLFileNameTC, sHTMLFileName
	Dim iRunNr, arrTempRunNr
	
	Environment.Value("Framework") = fnGetFolderPath("Framework")
	Dim sTestSetPath : sTestSetPath = Environment.Value("Framework")
	
	sHTMLFilePath = fnGetFolderPath("HTMLResult")
	
	If Not(fso.FolderExists(sHTMLFilePath)) Then
		fso.CreateFolder(sHTMLFilePath)		
	End If	
	
	sHTMLFilePath = sHTMLFilePath & fnGetDateStamp & "\"
	
	If Not(fso.FolderExists(sHTMLFilePath)) Then
		fso.CreateFolder(sHTMLFilePath)		
	End If
	
	sHTMLFilePath = sHTMLFilePath & Environment.Value("ExecutionID") & "\"
	
	If Not(fso.FolderExists(sHTMLFilePath)) Then
		fso.CreateFolder(sHTMLFilePath)		
	End If
	
	sHTMLFileName = Environment.Value("ExecutionID") &"_"& fnGetDateStamp & ".html" 

	dtDate = Date
		
	SQL = "Select * from[TestSet$] where Run = 'Y' And Result = 'Pass' And Last_Updated Like '%"& dtDate &"%'"
	arrPass = fnExcelDB_Read(sTestSetPath, "RunManager.xlsx", SQL)
	If Instr(1,arrPass(0,0),"Error") > 0 Then
		PassTCs = 0
	Else
		PassTCs = UBound(arrPass,1) + 1		
	End If	
	
	'SQL = "Select Product_Area, Scenario_Name, Test_Case_Name, Environment, Result, Last_Updated from[TestSet$] where Run = 'Y' And Result = 'Fail' And Last_Updated Like '%"& dtDate &"%'"
	SQL = "Select * from[TestSet$] where Run = 'Y' And Result = 'Fail' And Last_Updated Like '%"& dtDate &"%'"
	arrFail = fnExcelDB_Read(sTestSetPath, "RunManager.xlsx", SQL)
	If Instr(1,arrFail(0,0),"Error") > 0 Then
		FailTCs = 0
	Else
		FailTCs = UBound(arrFail,1) + 1		
	End If

	totalTCs = PassTCs + FailTCs
	
	'Writing HTML
	sText = "<HTML><BODY>"
	sText = sText & "<font>"
	sText = sText & "<p style=font-size:20><b>** ABSi Framework : Automated Test Execution Result ** <b></p>"
	sText = sText & "<p style=font-size:18><b>=> Execution ID = "&Environment.Value("ExecutionID")&"<b></p>"
	sText = sText & "<p style=font-size:18><b>=> Execution Date = "& Date &"<b></p>"

	'Adding Executional Data
	sText = sText & "<p style=font-size:18><b>=> Total TCs Executed = "& totalTCs &"<b></p>"	
	sText = sText & "<p style=font-size:18><b>=> Total TCs Passed = "& PassTCs &"<b></p>"	
	sText = sText & "<p style=font-size:18><b>=> Total TCs Failed = "& FailTCs &"<b></p>"
	sText = sText & "<br>"	
	sText = sText & "</font>"

	'Creating table
	sText = sText & "<TABLE border=2 font-family:Verdana Font-size=2 cellpadding=7>"
	sText = sText & "<TR align=middle>"
	sText = sText & "<TD bgcolor = lightgrey><b>PRODUCT AREA<b></TD>"
	sText = sText & "<TD bgcolor = lightgrey><b>TEST CASE NAME<b></TD>"
	sText = sText & "<TD bgcolor = lightgrey><b>ENVIRONMENT<b></TD>"
	sText = sText & "<TD bgcolor = lightgrey><b>RESULT<b></TD>"
	sText = sText & "<TD bgcolor = lightgrey><b>TIME<b></TD>"
	sText = sText & "</TR>"	

	If totalTCs > 0 Then
	
		SQL = "Select * from[TestSet$] where Run = 'Y' And Last_Updated Like '%"& dtDate &"%'"
		arrTCs = fnExcelDB_Read(sTestSetPath, "RunManager.xlsx", SQL)		
		
		For i = 0 To Ubound(arrTCs,1) Step 1
		
			arrTempRunNr = Split(Environment.Value("RunSessionID"),"_")
			iRunNr = CInt(arrTempRunNr(1)) - Cint((Ubound(arrTCs,1) - i))
			Select Case Len(iRunNr)
				Case 1
					iRunNr = "00" & iRunNr
				Case 2
					iRunNr = "0" & iRunNr
			End Select
			
			sHTMLFileNameTC = arrTempRunNr(0) &"_"& iRunNr & "_" & Environment.Value("Environment") & "_" & fnGetDateStamp &"_"&  Replace(arrTCs(i,3)," ","_") & ".html"	
		
			'sHTMLFileNameTC = Environment.Value("RunSessionID") & "_" & Environment.Value("Environment") & "_" & fnGetDateStamp &"_"&  Replace(arrTCs(i,3)," ","_") & ".html"	
						
			sText = sText & "<TR align=middle>"
			sText = sText & "<TD bgcolor = white>"&arrTCs(i,1)&"</TD>"
			sText = sText & "<TD bgcolor = white>"&arrTCs(i,3)&"</TD>"
			sText = sText & "<TD bgcolor = white>"&arrTCs(i,4)&"</TD>"
			If Instr(1,UCASE(arrTCs(i,6)),"PASS") > 0 Then	'Result
				sText = sText & "<TD bgcolor = green><a href="&sHTMLFilePath&sHTMLFileNameTC&">"&arrTCs(i,6)&"</a></TD>"
			ElseIf Instr(1,UCASE(arrTCs(i,6)),"FAIL") > 0 Then
				sText = sText & "<TD bgcolor = red><a href="&sHTMLFilePath&sHTMLFileNameTC&">"&arrTCs(i,6)&"</a></TD>"
			Else
				sText = sText & "<TD bgcolor = white>No Run</TD>"
			End If
			sText = sText & "<TD bgcolor = white>"&arrTCs(i,7)&"</TD>"
			sText = sText & "</TR>"		
	
		Next
		
	Else		
		sText = sText & "<TR align=middle>"
		sText = sText & "<TD bgcolor = white><b>No Data<b></TD>"
		sText = sText & "<TD bgcolor = white><b>No Test Cases Executed<b></TD>"
		sText = sText & "<TD bgcolor = white><b>No Data<b></TD>"
		sText = sText & "<TD bgcolor = white><b>No Data<b></TD>"
		sText = sText & "<TD bgcolor = white><b>No Data<b></TD>"
		sText = sText & "</TR>"					
	End If
	
	sText = sText & "</TABLE></BODY></HTML>"	
	
	Set objWrite = fso.CreateTextFile(sHTMLFilePath &"\"& sHTMLFileName,2)
	objWrite.Write sText
	objWrite.Close	
	Set objWrite = Nothing	
	Set fso = Nothing
	
	sHTMLFilePath = sHTMLFilePath & "\"
	
	SystemUtil.Run sHTMLFilePath & sHTMLFileName
	
	'To Send mail
	If UCase(Environment.Value("Sendmail")) = "YES" Then
		Call fnSendMail(sHTMLFilePath, sHTMLFileName)
	End If
	
	
End Function



Public Function fnGenerateHTMLTCDetails()

	Dim fso : Set fso = CreateObject("Scripting.FileSystemObject")
	Dim objWrite
	Dim SQL		
	Dim sHTMLFileNameTC, sHTMLFileName	
	Dim sTestCaseDetailsPath, sTestCaseDetailsFileName
	Dim dtStamp : dtStamp = fnGetDateStamp
	Dim fromDate, toDate, timeElapsedM, timeElapsedS, timeElapsed
	
	sTestCaseDetailsPath = fnGetFolderPath("ExcelResult") & dtStamp & "\" & Environment.Value("ExecutionID") & "\"
'	sTestCaseDetailsFileName = Environment.Value("ExecutionDetailsFileName")
	sTestCaseDetailsFileName = Environment.Value("RunSessionID") &"_"& Environment.Value("Environment") &"_" & dtStamp & "_" & Replace(Environment.Value("Test_Case_Name"), " ","_") & ".xlsx"
	
	sHTMLFilePath = fnGetFolderPath("HTMLResult")
	
	If Not(fso.FolderExists(sHTMLFilePath)) Then
		fso.CreateFolder(sHTMLFilePath)		
	End If	
	
	sHTMLFilePath = sHTMLFilePath & dtStamp & "\"
	
	If Not(fso.FolderExists(sHTMLFilePath)) Then
		fso.CreateFolder(sHTMLFilePath)		
	End If
	
	sHTMLFilePath = sHTMLFilePath & Environment.Value("ExecutionID") & "\"
	
	If Not(fso.FolderExists(sHTMLFilePath)) Then
		fso.CreateFolder(sHTMLFilePath)		
	End If
	
	sHTMLFileName = Environment.Value("RunSessionID") & "_" & Environment.Value("Environment") & "_" & dtStamp & "_" & Replace(Environment.Value("Test_Case_Name")," ","_") & ".html" 
		
	sText = "<HTML><BODY>"
	sText = sText & "<font>"
	sText = sText & "<br>"
	sText = sText & "<p style=font-size:20><b>Execution Details for TC = "&Environment.Value("Test_Case_Name")&"<b></p>"
	'sText = sText & "<br>"
	sText = sText & "<p style=font-size:20><b>Run Session ID = "&Environment.Value("RunSessionID")&"<b></p>"
	'sText = sText & "<br>"
	
	'RunSessionID" "ExecutionID" "Test_Case_ID" "Product_Area" "Scenario_Name" "Test_Case_Name" "Environment" "Step_Name" "Result" "LastUpdated" "ScreenshotPath" "EmailReport


	dtDate = Date
	'SQL = "Select Product_Area, Scenario_Name, Test_Case_Name, Environment, Result, Last_Updated from[TestSet$] where Run = 'Y' And Result = 'Pass' And Last_Updated Like '%"& dtDate &"%'"
	SQL = "Select * from[TestExceutionDetails$] where Email_Report = 'Y' And Last_Updated Like '%"& dtDate &"%'"
	arrStepDetails = fnExcelDB_Read(sTestCaseDetailsPath, sTestCaseDetailsFileName, SQL)
	
	sText = sText & "<TABLE border=2 font-family:Verdana Font-size=2 cellpadding=7>"
	sText = sText & "<TR align=middle>"
	sText = sText & "<TD bgcolor = lightgrey><b>TEST CASE ID<b></TD>"
	sText = sText & "<TD bgcolor = lightgrey><b>TEST CASE NAME<b></TD>"
	sText = sText & "<TD bgcolor = lightgrey><b>ENVIRONMENT<b></TD>"
	sText = sText & "<TD bgcolor = lightgrey><b>STEP NAME<b></TD>"
	sText = sText & "<TD bgcolor = lightgrey><b>STEP DATA<b></TD>"
	sText = sText & "<TD bgcolor = lightgrey><b>RESULT<b></TD>"
	sText = sText & "<TD bgcolor = lightgrey><b>TIME TAKEN<b></TD>"
	sText = sText & "<TD bgcolor = lightgrey><b>SCREENSHOT<b></TD>"
	sText = sText & "</TR>"		
	
	For i = 0 To Ubound(arrStepDetails,1) Step 1
	
		'sHTMLFileNameTC = Environment.Value("RunSessionID") & "_" & Replace(arrTCs(i,3)," ","_") & ".html"	
		
		sText = sText & "<TR align=middle>"
		sText = sText & "<TD bgcolor = white>"&arrStepDetails(i,2)&"</TD>"
		sText = sText & "<TD bgcolor = white>"&arrStepDetails(i,5)&"</TD>"
		sText = sText & "<TD bgcolor = white>"&arrStepDetails(i,6)&"</TD>"
		sText = sText & "<TD bgcolor = white>"&arrStepDetails(i,7)&"</TD>"
		sText = sText & "<TD bgcolor = white>"&arrStepDetails(i,8)&"</TD>"
		
		'Handling Result
		If Instr(1,UCASE(arrStepDetails(i,9)),"PASS") > 0 Then
			sText = sText & "<TD bgcolor = green>"&arrStepDetails(i,9)&"</TD>"		
'			sText = sText & "<TD bgcolor = green><a href="&sHTMLFilePath&sHTMLFileNameTC&">"&arrTCs(i,6)&"</a></TD>"
		ElseIf Instr(1,UCASE(arrStepDetails(i,9)),"FAIL") > 0 Then
			sText = sText & "<TD bgcolor = red>"&arrStepDetails(i,9)&"</TD>"		
'			sText = sText & "<TD bgcolor = red><a href="&sHTMLFilePath&sHTMLFileNameTC&">"&arrTCs(i,6)&"</a></TD>"
		Else
			sText = sText & "<TD bgcolor = white>No Run</TD>"
		End If
		
		'Handling Time taken
		If i = 0 Then
			timeElapsed = "Begin"
		Else
			fromDate = CDate(arrStepDetails(i-1,10))
			toDate = CDate(arrStepDetails(i,10)) 
'			timeElapsed = arrStepDetails(i,10)-arrStepDetails(i-1,10)
			timeElapsedM = DateDiff("n",fromDate,toDate)
			timeElapsedS = DateDiff("s",fromDate,toDate)
			timeElapsed  = timeElapsedM &":"& timeElapsedS
		End If
		sText = sText & "<TD bgcolor = white>"&timeElapsed&"</TD>"
		
		If Instr(1,arrStepDetails(i,11), "NA") > 0 Then
			sText = sText & "<TD bgcolor = white>NA</TD>"
		Else 
			sText = sText & "<TD bgcolor = white><a href="&arrStepDetails(i,11)&">View</a></TD>"			
		End If
		
		sText = sText & "</TR>"		

	Next
		
	sText = sText & "</TABLE></BODY></HTML>"
	
	Set objWrite = fso.CreateTextFile(sHTMLFilePath &"\"& sHTMLFileName,2)
	objWrite.Write sText
	objWrite.Close
	
	Set objWrite = Nothing
	Set fso = Nothing
	
	'SystemUtil.Run sHTMLFilePath &"\"& sHTMLFileName
	
End Function



Public Function fnUpdateReport(ByVal sStatus)

	Dim SQL
	Dim dtUpdated : dtUpdated = Now
	Dim sPath : sPath = fnGetFolderPath("Framework")
	
	SQL = "Update [TestSet$] Set Result = '" & sStatus & "', Last_Updated = '"& dtUpdated &"'"
	SQL = SQL & " Where Test_Case_ID = '" & Environment.Value("Test_Case_ID") & "'"
	SQL = SQL & " And Product_Area = '" & Environment.Value("Product_Area") & "'"
	SQL = SQL & " And Test_Case_Name = '" & Environment.Value("Test_Case_Name") & "'"
	SQL = SQL & " And Environment = '" & Environment.Value("Environment") & "'"
	
	fnTraceLogs "UPDATING RUN MANAGER SQL = " & SQL,1,1
	
	Call fnExcelDB_Write(sPath, "RunManager.xlsx", SQL)

	'To generate TC wise step details HTML Report File
	If UCASE(Environment.Value("HTMLReport")) = "YES" Then
		fnGenerateHTMLTCDetails
	End If
	
			
End Function



Sub fnSendMail(ByVal sFilePath, ByVal sFileName)  
 
  Dim oOutlook, oMail    
  Dim strFileText 
  Dim oText    

  Set oOutlook = CreateObject("Outlook.Application")    
  Set oMail = oOutlook.CreateItem(0)    
  Set oText = CreateObject("Scripting.FileSystemObject").OpenTextFile(sFilePath&sFileName, 1) 
  
  strFileText = oText.ReadAll()
  oText.Close
  Set oText = Nothing    
  
  With oMail    
    .To = Environment.Value("To")   
	.CC = Environment.Value("CC")
	.BCC = Environment.Value("BCC")
    .Subject = "ABSI :: Automated Test Execution :: " & Now()    
    .HTMLBody  = strFileText
	.Display    
'    .Send    
  End With
   
  Set oMail = Nothing    
  Set oOutlook = Nothing   
  
End Sub
