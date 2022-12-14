'#############################################################################################################################
'UTILITY FUNCTIONS - CONTAINS ALL FUNCTIONS RELATED TO FRAMEWORK
'#############################################################################################################################

'============================================================================================================================
'Function to get date in particular format ddmmyyyy
'============================================================================================================================
Function fnGetDateStamp()

	fnGetDateStamp = ""
	
	'2 Digit date formatting
	If Len(Day(Now)) = 1 Then
		fnGetDateStamp = fnGetDateStamp & "0" & Day(Now)
	Else
		fnGetDateStamp = fnGetDateStamp & Day(Now)
	End If
	'2 Digit month formatting
	If Len(Month(Now)) = 1 Then
		fnGetDateStamp = fnGetDateStamp & "0" & Month(Now)
	Else
		fnGetDateStamp = fnGetDateStamp & Month(Now)
	End If
	'4 Digit Year formatting
	If Len(Year(Now)) <> 4 Then
		fnGetDateStamp = fnGetDateStamp & "20" & Month(Now)
	Else
		fnGetDateStamp = fnGetDateStamp & Year(Now)
	End If
			
End Function

'============================================================================================================================
'Function to get date in particular format ddmmyyyy
'============================================================================================================================
Function fnCreateAndFetchScreenshotFolder()

	Dim ssPath : ssPath = fnGetFolderPath("Screenshots")
	ssPath = ssPath & fnGetDateStamp

	Dim fso : Set fso = CreateObject("Scripting.FileSystemObject")
	
	If Not(fso.FolderExists(ssPath)) Then
		fso.CreateFolder(ssPath)		
	End If	

	ssPath = ssPath &"\"& Environment.Value("ExecutionID")
	If Not(fso.FolderExists(ssPath)) Then
		fso.CreateFolder(ssPath)		
	End If	

	ssPath = ssPath &"\"& Environment.Value("RunSessionID") &"_"& Replace(Environment.Value("Test_Case_Name"), " ", "_") & "\"
	
	If Not(fso.FolderExists(ssPath)) Then
		fso.CreateFolder(ssPath)		
	End If
	
	Set fso = Nothing
	fnCreateAndFetchScreenshotFolder = ssPath
	
End Function

'============================================================================================================================
'Function to Capture Screenshot of the latest Java window open
'============================================================================================================================
Function fnTakeScreenShot_DesktopApplication()

	Dim ssPath : ssPath = fnCreateAndFetchScreenshotFolder	
    Dim objWindow : Set objWindow = Description.Create()    
    Dim SuggestedOptions, count, strDateNow, ssFileName, ssFullFileName
      
    objWindow("to_class").Value="JavaWindow" 
    objWindow("title").Value=".*<auf.*" 
    
    Set SuggestedOptions = Desktop.ChildObjects(objWindow)
    count = SuggestedOptions.Count
    SuggestedOptions(count-1).Activate

    strDateNow=Now()
    ssFileName = Replace(Replace(Replace(Replace(Replace(strDateNow,".",""),":","")," ","_"),"/",""), "-","")
    ssFullFileName = ssPath & "SS_" & ssFileName & ".png"
    SuggestedOptions(count-1).CaptureBitmap ssFullFileName

    Set SuggestedOptions = Nothing
    Set objWindow=Nothing
    
    fnTakeScreenShot_DesktopApplication = ssFullFileName
                
End Function

'============================================================================================================================
'Function to get date in particular format ddmmyyyy
'============================================================================================================================
Function fnGetDataFromDB (DBName, varSQL)

	Dim Conn
	Dim myarray()
	Dim nColCnt, nRowCnt
	Dim nColIdx, nRowIdx
	Dim objField
	Dim RecordSet, strConnString
	Dim varDSN, varUID, varPWD
	Dim o, p, errors, errorsconn, arrerr(),  arrerrconn(), text, textconn

	On Error Resume Next
	
	Select Case DBName
		Case "DTGEP10"			
			strConnString = "Provider=IBMDADB2.DB2COPY1; Database=DTGEP10;Hostname= sla20239.srv.allianz;currentSchema=ABS;Protocol=TCPIP;Port=51000;UID=geptsel;PWD=geptsel1;"
		Case "DTGEP45"
			strConnString = "Provider=IBMDADB2.DB2COPY1; Database=DTGEP45;Hostname= sla20239.srv.allianz;currentSchema=ABS;Protocol=TCPIP;Port=51000;UID=geptsel;PWD=geptsel1;"
		Case Else
			ReDim myarray(0,0)
			myarray(0,0)="Error|Invalid DB"
			fnGetDataFromDB = myarray
			Exit Function
	End Select

	Set Conn = CreateObject("ADODB.Connection")
''	Set Conn = CreateObject("OLEDB.Connection")
	Conn.ConnectionString = strConnString
	Conn.ConnectionTimeout = 60
	Conn.CommandTimeout = 60	
	Conn.Open
	
	
	If ( Conn.Errors.Count > 0 ) Then
		'Set Conn= Nothing
		ReDim myarray(0,0)
		myarray(0,0)="Error|Connection"
		fnGetDataFromDB=myarray
		errorsconn =Conn.Errors.Count
		ReDim arrerrconn(errorsconn)
		
		For o = 0 To errorsconn -1
			arrerrconn(o)= Conn.Errors.item(o).Description
			textconn="Connectionerror:  " & arrerrconn(o)
		Next
			
		Conn.Close
		Set Conn= Nothing
		Exit Function
	Else
		Set RecordSet = CreateObject("ADODB.Recordset")
		RecordSet.Open varSQL, Conn
		'Checking for SQL-Failure
		If (Conn.Errors.Count > 0)  Then  'RecordSet.State="0" Then			
			errors=Conn.Errors.Count
			ReDim arrerr(errors)
			For p = 0 To errors-1
				arrerr(p) = Conn.Errors.item(p).Description
				text="SQLERROR:  " & arrerr(p)					
			Next
			RecordSet.Close
			Conn.Close
			Set RecordSet = Nothing
			Set Conn = Nothing
			ReDim myarray(0,0)
			myarray(0,0)="Error|False"
			fnGetDataFromDB=myarray
			Exit Function
		End IF
		If ( RecordSet.EOF ) Then	'No errors but No data are found (return NULL)
			RecordSet.Close
			Conn.Close
			Set RecordSet	= Nothing
			Set Conn= Nothing
			ReDim myarray(0,0)
			myarray(0,0) = "Error|NULL"
			fnGetDataFromDB = myarray
			Exit Function
		End If
		'
		nRowCnt	= 0	' count the rows obtained
		RecordSet.MoveFirst
		Do While ( NOT RecordSet.EOF  And  nRowCnt < 20000 )'avoid endless loop
			RecordSet.MoveNext
			nRowCnt = nRowCnt+1
		Loop

		If ( nRowCnt <= 0 )	Then
			ReDim myarray(0,0)
			myarray(0,0)="NULL"
		Else
			nColCnt	= RecordSet.fields.count		
			'ReDim  myarray ( CInt(nRowCnt -1), nColCnt -1 )
			ReDim  myarray ( CInt(nRowCnt), nColCnt -1 ) ' Adding this to cater Columns Names also
			RecordSet.MoveFirst
			nRowIdx	= 0		' fetch over result rows
			Do While (  Not RecordSet.EOF  And  nRowIdx < 20000 )	' avoid endless loop
				nColIdx	= 0				
				'Get Column Names of Table into array
				If nRowIdx	= 0 Then
					For Each objField in RecordSet.Fields	
						myarray ( nRowIdx, nColIdx ) = objField.Name
						nColIdx	= nColIdx +1
					Next
					nRowIdx	= nRowIdx +1					
				End If				

				'Get all Values in Table into array
				nColIdx	= 0
				For Each objField in RecordSet.Fields	
					myarray ( nRowIdx, nColIdx ) = objField.Value
					nColIdx	= nColIdx +1
				Next
				RecordSet.MoveNext
				nRowIdx	= nRowIdx +1
			Loop
		End If 'nRowCnt <= 0
		fnGetDataFromDB	= myarray
		RecordSet.Close
		Conn.Close
		Set RecordSet = Nothing
		Set Conn = Nothing
	End If

End Function

'============================================================================================================================
'Function to get date in particular format ddmmyyyy
'============================================================================================================================
Function fnExcelDB_ReadWithColumn(Byval sLocation, Byval sXLname, Byval sQuery)

	Const adOpenStatic = 3
	Const adLockOptimistic = 3
	Const adCmdText = "&H0001"
	Dim arrFetchedData()
	ReDim arrFetchedData(0,0)
	
	Err.Clear
	'On Error Resume Next	
			
	Set objConnection = CreateObject("ADODB.Connection")
	Set objRecordSet = CreateObject("ADODB.Recordset")
	
	Set fso  = CreateObject("Scripting.FileSystemObject")
	If fso.FolderExists(sLocation) Then
		If fso.FileExists(sLocation&sXLname) Then
'			objConnection.Open "Provider=Microsoft.Jet.OLEDB.4.0;" & "Data Source=" & sLocation & sXLname & ";" & "Extended Properties=""Excel 8.0; HDR=Yes;"";"
			objConnection.Open "Provider=Microsoft.ACE.OLEDB.12.0;" & "Data Source=" & sLocation & sXLname & ";" & "Extended Properties=""Excel 12.0; HDR=Yes;"";"	
			If objConnection.State = 1 Then
				objRecordset.Open sQuery , objConnection, adOpenStatic, adLockOptimistic, adCmdText
				If objRecordset.State = 1 Then
				
					If objRecordset.RecordCount > 0 Then
						'Creating Dynamic Dictionary
						ReDim  arrFetchedData(objRecordset.recordcount, objRecordset.Fields.Count)				
						'getting column names
						For j=0 to objRecordset.Fields.count-1	
							arrFetchedData(0,j) = objRecordset.fields(j).Name
						Next
						
						Dim i : i = 1
						Dim j
						'Getting Values
						While objRecordset.EOF=false		
							For j=0 to objRecordset.Fields.count-1	
								arrFetchedData(i,j) = objRecordset.fields(j)
							Next
							i = i+1
							objRecordset.moveNext
						Wend
					Else
						arrFetchedData(0,0) = "Error|No Data Found|Exit"					
					End If					
					
					objRecordset.Close				
				Else
					arrFetchedData(0,0) = "Error|SQL Error|Exit"					
				End If	
				objConnection.Close
			Else
				arrFetchedData(0,0) = "Error|Connection Failed|Exit"
			End If
		Else
			arrFetchedData(0,0) = "Error|File not found|Exit"	
		End If
	Else
		arrFetchedData(0,0) = "Error|Folder not found|Exit"
	End If
	
	'On Error GoTo 0
	
	fnExcelDB_ReadWithColumn = arrFetchedData
	
End Function

'============================================================================================================================
'Function to get date in particular format ddmmyyyy
'============================================================================================================================
Public Function fnGetUniqueExcecutionID()

	Dim SQL, sPath, sFile, RetVal, Id, temp
	fnGetUniqueExcecutionID = ""
	SQL = "Select ExecutionID from [UniqueIDs$]"
	sPath = fnGetFolderPath("Resources")
	sFile = "UniqueIDTable.xlsx"
	RetVal = fnExcelDB_Read(sPath, sFile, SQL)
	Id = RetVal(0,0)
	temp = Split(Id,"_")
	fnGetUniqueExcecutionID = temp(0) &"_"& CLng(temp(1))+1
	
	SQL = "Update [UniqueIDs$] Set ExecutionID = '" & fnGetUniqueExcecutionID &"'"
	Call fnExcelDB_Write(sPath, sFile, SQL)
	
	Call fnTraceLogs("EXECUTION ID = " & fnGetUniqueExcecutionID, 1, 1)
	
End Function

'============================================================================================================================
'Function to get date in particular format ddmmyyyy
'============================================================================================================================
Public Function fnGetUniqueRunSessionID()

	Dim SQL, sPath, sFile, RetVal, Id, temp
	fnGetUniqueRunSessionID = ""
	SQL = "Select RunSessionID from [UniqueIDs$]"
	sPath = fnGetFolderPath("Resources")
	sFile = "UniqueIDTable.xlsx"
	RetVal = fnExcelDB_Read(sPath, sFile, SQL)
	Id = RetVal(0,0)
	temp = Split(Id,"_")
	fnGetUniqueRunSessionID = temp(0) &"_"& CLng(temp(1))+1
	
	SQL = "Update [UniqueIDs$] Set RunSessionID = '" & fnGetUniqueRunSessionID &"'"
	Call fnExcelDB_Write(sPath, sFile, SQL)
	
	Call fnTraceLogs("RUN SESSION ID = " & fnGetUniqueRunSessionID, 1, 1)
	
End Function


Public Function fnGetFolderPath(ByVal reqFolder)

	Dim fwPath
	
	fwPath = Replace(Environment.Value("TestDir"),Environment.Value("TestName"),"")

	Select Case reqFolder
	
		Case "Framework"
			fnGetFolderPath = fwPath
		Case "FunctionLibrary"
			fnGetFolderPath = fwPath & "FunctionLibrary"
		Case "ObjectRepository"
			fnGetFolderPath = fwPath & "ObjectRepository"
		Case "Resources"
			fnGetFolderPath = fwPath & "Resources\"
		Case "ExcelResult"
			fnGetFolderPath = fwPath & "Results\ExcelResult\"
		Case "HTMLResult"
			fnGetFolderPath = fwPath & "Results\HTMLResult\"
		Case "Logs"
			fnGetFolderPath = fwPath & "Results\Logs\"
		Case "Screenshots"
			fnGetFolderPath = fwPath & "Results\Screenshots\"
		Case "TestData"
			fnGetFolderPath = fwPath & "TestData\"
		Case Else
			fnGetFolderPath = "Error|Invalid Type of Folder requested|Exit"	
			Exit Function
	End Select

	If fnCheckFolderExists(fnGetFolderPath) <> "True" Then
		fnGetFolderPath = fnCheckFolderExists
	End If
	
End Function

Public Function fnCheckFolderExists(ByVal sPath)

	Dim fso
	Set fso = CreateObject("Scripting.FileSystemObject")
	fnCheckFolderExists = "True"
	If Not(fso.FolderExists(sPath)) Then
		fnCheckFolderExists = "Error|Folder Not Found|Exit"	
	End If
	
	Set fso = Nothing
	
End Function

Public Function fnCheckFileExists(ByVal sPath, ByVal sFileName)

	Dim fso
	Set fso = CreateObject("Scripting.FileSystemObject")
	fnCheckFileExists = "True"	
	
	If fnCheckFolderExists(sPath) = "True" Then
		If Not(fso.FileExists(sPath&sFileName)) Then
			fnCheckFileExists = "Error|File Not Found|Exit"
		End If
	Else
		fnCheckFileExists = fnCheckFolderExists
	End If
	
	Set fso = Nothing
	
End Function

Public Function fnExcelDB_Read(Byval sLocation, Byval sXLname, Byval sQuery)

	Const adOpenStatic = 3
	Const adLockOptimistic = 3
	Const adCmdText = "&H0001"
	Dim arrFetchedData()
	ReDim arrFetchedData(1,1)
	Set objConnection = CreateObject("ADODB.Connection")
	Set objRecordSet = CreateObject("ADODB.Recordset")
	
	Set fso  = CreateObject("Scripting.FileSystemObject")
	If fso.FolderExists(sLocation) Then
		If fso.FileExists(sLocation&sXLname) Then
'			objConnection.Open "Provider=Microsoft.Jet.OLEDB.4.0;" & "Data Source=" & sLocation & sXLname & ";" & "Extended Properties=""Excel 8.0; HDR=Yes;"";"
			objConnection.Open "Provider=Microsoft.ACE.OLEDB.12.0;" & "Data Source=" & sLocation & sXLname & ";" & "Extended Properties=""Excel 12.0; HDR=Yes;"";"
			objRecordset.Open sQuery , objConnection, adOpenStatic, adLockOptimistic, adCmdText
			
			If objRecordset.RecordCount > 0 Then
			
				ReDim  arrFetchedData(objRecordset.recordcount -1, objRecordset.Fields.Count-1)
		
				Dim i : i = 0
				While objRecordset.EOF=false		
					For j=0 to objRecordset.Fields.count-1	
						arrFetchedData(i,j)= objRecordset.fields(j)
					Next
					i = i+1
					objRecordset.moveNext
				Wend
			
				objRecordset.Close
				objConnection.Close			
			
			Else
				arrFetchedData(0,0) = "Error|Data not found|Exit"
			End If
		Else
			arrFetchedData(0,0) = "Error|File not found|Exit"	
		End If
	Else
		arrFetchedData(0,0) = "Error|Folder not found|Exit"
	End If
	
	fnExcelDB_Read = arrFetchedData
	
End Function

Public Function fnExcelDB_Write(Byval sLocation, Byval sXLname, Byval sQuery)
	
	 Dim cmdCommand : Set cmdCommand = CreateObject("ADODB.Command")
	 Dim recSet :  Set recSet = CreateObject("ADODB.Recordset")
	 Dim cn : Set cn = CreateObject("ADODB.Connection")

	 cn.ConnectionString = "Provider=Microsoft.ACE.OLEDB.12.0;" & "Data Source=" & sLocation & sXLname & ";" & "Extended Properties=""Excel 12.0; HDR=Yes;"";"
	 cn.Open()
	 cmdCommand.ActiveConnection = cn 
 
 	cmdCommand.CommandText = sQuery
 	cn.Execute sQuery
 	
'  	'The update syntax
'  	If cn.State = 1 Then
'  		Set recSet = cmdCommand.Execute()
'  		If recSet.Fields.Count = 0 Then
'  			fnExcelDB_Write = "True"
'  		Else
'  			fnExcelDB_Write = "Error|Records not updated|Exit"
'  		End If
'  	Else 
'  		fnExcelDB_Write = "Error|Connection not created|Exit"	
'  	End If
	  
	Set cmdCommand = Nothing
	Set recSet = Nothing
	Set cn = Nothing
	
End Function



Public Function fnCreateTCExecutionDetailsFile(ByVal sFile)

	Dim sPath : sPath = fnGetFolderPath("ExcelResult")
	Dim sFileName : sFileName = sFile
	Dim oXL, oWB, oSheet, fso
	
	Set fso = CreateObject("Scripting.FileSystemObject")
	
	sPath = sPath & fnGetDateStamp &"\"
	
	If Not(fso.FolderExists(sPath)) Then
		fso.CreateFolder(sPath)		
	End If	

	sPath = sPath & Environment.Value("ExecutionID") &"\"
	
	If Not(fso.FolderExists(sPath)) Then
		fso.CreateFolder(sPath)		
	End If

	'Create Execution Details File if not already present
	If Not(fso.FileExists(sPath&sFileName)) Then
	
		Set oXL =  CreateObject("Excel.Application")
		Set oWB = oXL.Workbooks.Add(1)
		oXL.Visible = False
		oXL.DisplayAlerts = False	
			
		Set oSheet = oWB.Worksheets(1)
		oSheet.Name = "TestExceutionDetails"
		
		arrColNames = Array("RunSessionID", "ExecutionID", "Test_Case_ID", "Product_Area", "Scenario_Name", "Test_Case_Name", "Environment", "Step_Name", "Step_Data", "Result", "Last_Updated", "Screenshot_Path", "Email_Report")
		For i = 0 To Ubound(arrColNames) Step 1
			oSheet.Cells(1,i+1) = Trim(arrColNames(i))		
		Next
		oSheet.Range("A:M").ColumnWidth = 40
		oWB.SaveAs sPath&sFileName
		oWB.Close
		oXL.Quit
			
		Set oSheet = Nothing
		Set oWB = Nothing
		Set oXL = Nothing
		Set fso = Nothing
		
		fnTraceLogs "Execution Details Sheet Created = " & sFileName,4,1
				
	End If
		
	fnCreateTCExecutionDetailsFile = sPath
	
End Function


Public Function fnUpdateExecutionDetailsXL(Byval sStep, ByVal sStepData, Byval sResult, Byval Screenshot, Byval sEmailReport)

	Dim ScreenshotPath, sPath	
	Dim sFileName : sFileName = Environment.Value("RunSessionID") & "_" & Environment.Value("Environment") & "_" & fnGetDateStamp & "_" & Replace(Environment.Value("Test_Case_Name")," ","_") & ".xlsx"
				
	sPath = fnCreateTCExecutionDetailsFile(sFileName)		
		
	If UCase(Screenshot) = "Y" Then
		ScreenshotPath = fnTakeScreenShot_DesktopApplication
	ElseIf UCase(Environment.Value("OnErrorScreenShot")) = "YES" AND UCASE(sResult) = "FAIL" Then
		ScreenshotPath = fnTakeScreenShot_DesktopApplication
	Else
		ScreenshotPath = "NA"
	End If
	
	If sStepData = "" Or IsEmpty(sStepData) Then
		sStepData = "NA"		
	End If
	
	sTime = Now()
		
	SQL = "Insert INTO [TestExceutionDetails$] (RunSessionID, ExecutionID, Test_Case_ID, Product_Area, Scenario_Name, Test_Case_Name, Environment, Step_Name, Step_Data, Result, Last_Updated, Screenshot_Path, Email_Report) "
	SQL = SQL & "Values ('" & Environment.Value("RunSessionID") &"', "
	SQL = SQL & "'" & Environment.Value("ExecutionID") &"', " 
	SQL = SQL & "'" & Environment.Value("Test_Case_ID") &"', "
	SQL = SQL & "'" & Environment.Value("Product_Area") &"', "
	SQL = SQL & "'" & Environment.Value("Scenario_Name") &"', "
	SQL = SQL & "'" & Environment.Value("Test_Case_Name") &"', "
	SQL = SQL & "'" & Environment.Value("Environment") &"', "
	SQL = SQL & "'" & sStep &"', "
	SQL = SQL & "'" & sStepData &"', "
	SQL = SQL & "'" & sResult &"', "
	SQL = SQL & "'" & sTime &"', "
	SQL = SQL & "'" & ScreenshotPath &"', "
	SQL = SQL & "'" & sEmailReport &"')"
	
	Call fnExcelDB_Write(sPath, sFileName, SQL)
		
End Function


Public Function fnTraceLogs(ByVal sLogMsg, Byval iTraceLevel, ByVal iTraceType)

	fnTraceTextLogs = ""
	Dim arrTrace
	RetVal = fnTraceLevel(iTraceLevel)
	If RetVal Then
		arrTrace = fnTraceType(iTraceType)
		For i = 0 To UBound(arrTrace) Step 1
			Select Case arrTrace(i)
				Case "text"
					Call fnGenerateLogFileAndMsg(sLogMsg)
				Case "excel"
			End Select			
		Next
		
	End If
	
End Function

Function fnTraceType(ByVal sTraceType)

	fnTraceType = ""	
	
	If sTraceType = 1 Then
		arrTrace = Array("text")
	ElseIf sTraceType = 2 Then
		arrTrace = Array("excel")
	ElseIf sTraceType = 3 Then
		arrTrace = Array("text","excel")
	End If
	
	fnTraceType = arrTrace
	
End Function

Function fnTraceLevel(ByVal iTraceLevel)

	fnTraceLevel = ""	
	'If CInt(iTraceLevel) < Cint(dictConfig("TraceLevel")) Then
	If CInt(iTraceLevel) < Cint(Environment.Value("TraceLevel")) Then
		fnTraceLevel = True
	Else
		fnTraceLevel = False
	End If	
	
End Function



Function fnGenerateLogFileAndMsg(ByVal sLogMsg)	

	Dim sLogFileName : sLogFileName = "ExecutionLog_" & fnGetDateStamp & ".log"
	Dim sLogFilePath : sLogFilePath = fnGetFolderPath("Logs")
	
'	sLogFileName = sLogFileName & fnGetDateStamp
'	sLogFileName = sLogFileName & ".log"
	
	sLogMsg = Now & " | " & sLogMsg	
	
	
	If fnCheckFileExists(sLogFilePath, sLogFileName) = "True" Then
		Call fnWriteTextFile(sLogFilePath, sLogFileName, sLogMsg)
	Else
		Call fnCreateTextFile(sLogFilePath, sLogFileName)
		Call fnWriteTextFile(sLogFilePath, sLogFileName, sLogMsg)
	End If
				
End Function


Function fnCreateTextFile(ByVal sLocation, ByVal sFile)

	Dim fso : Set fso = CreateObject("Scripting.FileSystemObject")
	Dim oText : Set sText = fso.CreateTextFile(sLocation & sFile, 2)

	Set oText = Nothing
	Set fso = Nothing
	fnCreateTextFile = "True"
	
End Function

Function fnWriteTextFile(ByVal sLocation, ByVal sFile, ByVal sMsg)

	Dim fso : Set fso = CreateObject("Scripting.FileSystemObject")
	Dim oText : Set oText = fso.OpenTextFile(sLocation & sFile, 8)
	oText.Writeline sMsg
	
	Set oText = Nothing
	Set fso = Nothing
	
End Function


Function fnGetTestData(ByVal TestDataSearchParameter, ByRef dictTCDataTemp)
	
	Dim arrData, arrTemp, sLocation, sXLName, SQL
	Dim i, iRunID
	
	iRunID = fnGetUniqueRunSessionID
	arrTemp = TestDataSearchParameter
	sLocation = fnGetFolderPath("TestData")	
	sXLName = arrTemp(1) & ".xlsx" 	
	SQL = "Select * from [" & arrTemp(2) &"$] where Test_Case_ID = '" & arrTemp(0) & "' AND Test_Case_Name = '" & arrTemp(3) & "' AND Used_Flag = 'F' "
	fnTraceLogs "Fetching Test Data SQL :" & SQL,1,1
	
	'Put important Details from RunManager to Env Var
	Environment.Value("Test_Case_ID") = Trim(arrTemp(0))	
	Environment.Value("Product_Area") = Trim(arrTemp(1))
	Environment.Value("Scenario_Name") = Trim(arrTemp(2))
	Environment.Value("Test_Case_Name") = Trim(arrTemp(3))
	Environment.Value("Environment") = Trim(arrTemp(4))
	Environment.Value("RunSessionID") = iRunID
	
	'Put important Details from RunManager to TC data Dict
	dictTCDataTemp("Product_Area") = Trim(arrTemp(1))
	dictTCDataTemp("Scenario_Name") = arrTemp(2)
	dictTCDataTemp("ExecutionID") = Environment.Value("ExecutionID")	
	dictTCDataTemp("RunSessionID") = iRunID
		
	'Reading Data with column names
	arrData = fnExcelDB_ReadWithColumn(sLocation, sXLName, SQL)
	
	'Set Global Dictionary for TC wise Test Data	
	If Instr(1,arrData(0,0),"Error") > 0 Then
		dictTCDataTemp("TCDataAvailability") = "No"
	Else
		For i = 0 To UBound(arrData,2) Step 1
			dictTCDataTemp(arrData(0,i)) = arrData(1,i)		
		Next
		dictTCDataTemp("TCDataAvailability") = "Yes"		
	End If
		
End Function



Function fnWriteDictionaryDetails(ByVal d)

	For Each k in d.Keys
		fnTraceLogs k & " = " & d(k),4,1
	Next
	
End Function



Function fnSetUpEnvironmentVariables(ByRef dictConfig)

	Dim exID
	For each k in dictConfig.Keys
		Environment.Value(k) = dictConfig(k)		
	Next
	exID = fnGetUniqueExcecutionID
	Environment.Value("ExecutionID") = Trim(exID)
	
End Function


Function fnSetUpConfig(ByRef dictConfig)

	Dim fso : Set fso = CreateObject("Scripting.FileSystemObject")
	Dim oText : Set oText = fso.OpenTextFile(fnGetFolderPath("Framework") & "Config.txt", 1)
	Dim sTemp
	Do While Not(oText.AtEndOfStream)
		sTemp = oText.Readline
		arrTemp = Split(sTemp,"=")
		dictConfig(Trim(arrTemp(0))) = Trim(arrTemp(1))
	Loop
	
	Set oText = Nothing
	Set fso = Nothing
	
End Function

Function fnUpdateReport(ByVal sStatus)

	Dim SQL
	Dim dtUpdated : dtUpdated = Now
	Dim sPath : sPath = fnGetFolderPath("Framework")
	
	SQL = "Update [TestSet$] Set Result = '" & sStatus & "', Last_Updated = '"& dtUpdated &"'"
	SQL = SQL & " Where Test_Case_ID = '" & Environment.Value("Test_Case_ID") & "'"
	SQL = SQL & " And Product_Area = '" & Environment.Value("Product_Area") & "'"
	SQL = SQL & " And Test_Case_Name = '" & Environment.Value("Test_Case_Name") & "'"
	SQL = SQL & " And Environment = '" & Environment.Value("Environment") & "'"
	
	Call fnExcelDB_Write(sPath, "RunManager.xlsx", SQL)

	fnGenerateHTMLTCDetails
	
		
End Function


Public Function fnUpdateExecutionDetailsXL_Method2(Byval sStep, ByVal sStepData, Byval sResult, Byval Screenshot, Byval sEmailReport)

	Dim ScreenshotPath, sPath	
	Dim sFileName : sFileName = Environment.Value("RunSessionID") & "_" & Environment.Value("Environment") & "_" & fnGetDateStamp & "_" & Replace(Environment.Value("Test_Case_Name")," ","_") & ".xlsx"
				
	sPath = fnCreateTCExecutionDetailsFile(sFileName)		
		
	If UCase(Screenshot) = "Y" AND UCase(Environment.Value("StepScreenShot")) = "YES" Then
		ScreenshotPath = fnTakeScreenShot_DesktopApplication
	ElseIf UCase(Environment.Value("OnErrorScreenShot")) = "YES" AND UCASE(sResult) = "FAIL" Then
		ScreenshotPath = fnTakeScreenShot_DesktopApplication
	Else
		ScreenshotPath = "NA"
	End If
	
	If sStepData = "" Or IsEmpty(sStepData) Then
		sStepData = "NA"		
	End If
	
	sTime = Now()
	
	Set cnExcel = CreateObject("ADODB.Connection")
	
	ConnS = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source="&sPath&sFileName&";Extended Properties=""Excel 12.0;HDR=YES"""
	cnExcel.ConnectionString = ConnS
	cnExcel.open
	
	Set objRecordSet = CreateObject("ADODB.Recordset")
	Set objRecordSet.ActiveConnection = cnExcel
	objRecordSet.locktype = 3
	objRecordSet.cursorlocation = 3

	sQuery = "Select *  from [TestExceutionDetails$] where 1=2;"

	objRecordSet.open sQuery
	objRecordSet.AddNew
	objRecordSet.Fields("RunSessionID") = "Abhishek"
	objRecordSet.Fields("ExecutionID") = "Sinha"
	objRecordSet.Fields("Test_Case_ID") = "Abhishek"
	objRecordSet.Fields("Product_Area") = "Sinha"
	objRecordSet.Fields("Scenario_Name") = "Abhishek"
	objRecordSet.Fields("Test_Case_Name") = "Sinha"
	objRecordSet.Fields("Environment") = "Abhishek"
	objRecordSet.Fields("Step_Name") = "Sinha"
	objRecordSet.Fields("Step_Data") = "Abhishek"
	objRecordSet.Fields("Result") = "Sinha"
	objRecordSet.Fields("Last_Updated") = "Abhishek"
	objRecordSet.Fields("Screenshot_Path") = "Sinha"
	objRecordSet.Fields("Email_Report") = "Sinha"
	objRecordSet.Update
	
	If Err.Number <> 0 Then
	   msgbox "err"
	End If
	objRecordSet.Close
	Set objRecordSet = nothing
	cnExcel.Close
	Set cnExcel = nothing
	'On Error GoTo 0
	
End Function


