'Dim dict
'Set dict = CreateObject("Scripting.Dictionary")
'dict.Add "Person_FirstName", "test" 
'dict.Add "Person_SecondName", "test"
'dict.Add "Legal_Person", "YES"
'dict.Add "Person_DOB", "10.12.1989"


	
Public Function fnEnterData(ByRef vObject, ByVal sValue)  

    On Error Resume Next
    Err.Clear
    Dim sMsg : sMsg = "" 
    Dim fn_Name : fn_Name = "fnEnterData"
    fnEnterData = False
   
    sValue = Trim(sValue)    
    vClass = vObject.GetToProperty("TestObjName")
    vClass = Replace(vClass,left(vClass,3),"")
    iClass = vObject.GetRoProperty("micclass")
    ObjectType = vObject.GetRoProperty("Class Name")
    vObject.RefreshObject
    If sValue <> "" Then
        If vObject.Exist (10) then
	        If Left(ObjectType,4) = "Java" Then
	                'vObject.Click
	                vObject.Type sValue
	        else                
	                vObject.set sValue
	      	End If
	       
	        If Err.Number = 0 Then
	            fnEnterData = True                 
	            sMsg =  sValue & " Data entered | PASS"
	        Else                 
	           sMsg =  sValue & " No data entered | FAIL"
	        End If
        Else             
            sMsg =  sValue & " No data entered | FAIL"
        End If
    End If
	
    If Instr(1,sMsg,"PASS") Then
     fnEnterData = True
     fnUpdateExecutionDetailsXL "Data entered", sValue, "Pass", "N", "Y"
    ElseIf Instr(1,sMsg,"FAIL")Then
     	fnUpdateExecutionDetailsXL "Data entered", sValue, "Fail", "N", "Y"
    End If
        
    fnTraceLogs fn_Name & " | DataEntered | " & sMsg,4,1
    
    On Error GoTo 0
    
End Function


Public Function fnClickDialogBoxButton(ByRef vObject, ByVal btnName)
                                                 
    On Error Resume Next
    Err.Clear
    Dim fn_Name : fn_Name = "fnClickDialogBoxButton"
    Dim sMsg : sMsg = ""
    fnClickDialogBoxButton = True   

    If vObject.GetROProperty("to_class") = "JavaWindow" Then
        Set oButton=vObject.JavaButton("label:="&btnName)
        oButton.Click
        If Err.Number <> 0 Then
            fnClickDialogBoxButton = False
        End If
    End If
          
    If fnClickDialogBoxButton Then
        sMsg = "Button Clicked | PASS"    
        fnTraceLogs fn_Name & " | Click Dialog Box Button | " & btnName & " | " & sMsg,4,1    
        fnUpdateExecutionDetailsXL "Click Dialog Box Button", btnName, "Pass", "N", "Y"
    Else
     sMsg = "Button not Clicked | FAIL"
        fnTraceLogs fn_Name & " | " & btnName & " | " & sMsg,4,1     
        fnUpdateExecutionDetailsXL "Click Dialog Box Button", btnName, "Fail", "N", "Y"
    End If
    
    On Error GoTo 0
    
End Function


Public Function fnSelectRadioButton(ByRef vObject, ByVal rbName)

    On error resume next
   	Err.Clear
    Dim fn_Name : fn_Name = "fnSelectRadioButton"
    Dim sMsg : sMsg = ""    
    fnSelectRadioButton = False   
    
    strClassName = vObject.GetROProperty("to_class")  
    
    If vObject.Exist(10) Then                                                
        If strClassName = "JavaRadioButton" Then
            vObject.Set          
        End If 
        
        If Err.Number = 0 Then           
            sMsg = "Radio Button Clicked | PASS" 
        Else         
         sMsg = "Radio Button not Clicked | FAIL" 
        End If
    Else  
         sMsg = "Radio Button not found | FAIL"      
    End If
    
    If Instr(1,sMsg,"PASS") Then
     fnSelectRadioButton = True
     fnUpdateExecutionDetailsXL "Select Radio Button", rbName, "Pass", "N", "Y"
    ElseIf Instr(1,sMsg,"FAIL")Then
     fnUpdateExecutionDetailsXL "Select Radio Button", rbName, "Fail", "N", "Y"
    End If   
    
    fnTraceLogs fn_Name & " | " & rbName & " | " & sMsg,4,1 
    
    On Error Goto 0
    
End Function


Public Function fnMaximizeJavaWindow()

    On error resume next
   	Err.Clear
   	Dim fn_Name : fn_Name = "fnMaximizeJavaWindow"
    Dim sMsg : sMsg = "" 
    Dim SuggestedOptions, count
    Dim objWindow : Set objWindow = Description.Create()

    fnMaximizeJavaWindow = False   
    
    objWindow("to_class").Value="JavaWindow" 
    Set SuggestedOptions = Desktop.ChildObjects(objWindow)
    count = SuggestedOptions.Count
    
    If count > 0 AND Err.Number = 0 Then
     SuggestedOptions(count-1).Maximize
     sMsg = "Java Window Maximized | PASS" 
    Else
     sMsg = "Java Window Maximized | FAIL" 
    End If
    
    If Instr(1,sMsg,"PASS") Then
     fnMaximizeJavaWindow = True
     fnUpdateExecutionDetailsXL "Java Window Maximized", "", "Pass", "N", "Y"
    ElseIf Instr(1,sMsg,"FAIL")Then
     fnUpdateExecutionDetailsXL "Java Window not Maximized", "", "Fail", "N", "Y"
    End If   
    
    fnTraceLogs fn_Name & " | Java Window | " & sMsg,4,1 
    
    On Error Goto 0

End Function


Public Function fnSelectCheckBox(ByRef vObject, ByVal chkboxName)                                    
   
   On Error Resume Next
   Err.Clear    
   Dim sMsg : sMsg = "" 
   Dim fn_Name : fn_Name = "fnSelectCheckBox"
   fnSelectCheckBox = False
   
    strClassName = vObject.GetROProperty("to_class")
    
    If vObject.Exist(10) Then
        If strClassName = "JavaCheckBox" and vObject.GetROProperty("value") = 0 Then              
            vObject.Set "ON"
        End If
        If Err.Number = 0 Then
            fnClickWinCheckBox = True 
                sMsg =  chkboxName & " CheckBox Selected | PASS"
                Else
                sMsg =  chkboxName & " CheckBox not Selected | FAIL" 
        End If
    End If
    
    If Instr(1,sMsg,"PASS") Then
     fnSelectCheckBox = True
     fnUpdateExecutionDetailsXL "CheckBox Selected", chkboxName, "Pass", "N", "Y"
    ElseIf Instr(1,sMsg,"FAIL")Then
     	fnUpdateExecutionDetailsXL "CheckBox not Selected", chkboxName, "Fail", "N", "Y"
    End If
        
    fnTraceLogs fn_Name & " | CheckBox | " & sMsg,4,1
    On Error Goto 0
    
End Function


Public Function fnCheckObjectExist(ByRef vObject, ByVal objName)
                
    On Error Resume Next
    Err.Clear
    Dim sMsg : sMsg = "" 
    Dim fn_Name : fn_Name = "fnCheckObjectExist"
    fnCheckObjectExist = False
    
    vClass = vObject.GetToProperty("TestObjName")
    vClass = Replace(vClass,left(vClass,3),"")
    If vObject.GetRoProperty("Class Name") <> "JavaTable" Then
       vObject.RefreshObject
    End If
    
    If vObject.Exist(5) Then
        If Err.Number = 0 Then
     		sMsg = " Object Exist | PASS" 
            fnCheckObjectExist = True
        Else
     sMsg = " Object does not Exist | FAIL"           
        End If
    End If
    
    If Instr(1,sMsg,"PASS") Then
     fnCheckObjectExist = True
     fnUpdateExecutionDetailsXL "Check Object Exist", objName, "Pass", "N", "Y"
    ElseIf Instr(1,sMsg,"FAIL")Then
     	fnUpdateExecutionDetailsXL "Check Object Exist", objName, "Fail", "N", "Y"
    End If
        
    fnTraceLogs fn_Name & " | ObjectExist | " & sMsg,4,1
    
    On Error Goto 0    
    
End Function


Public Function fnButtonClick(ByRef vObject, Byval btnName)   
    On Error Resume Next
    Err.Clear
    Dim sMsg : sMsg = "" 
    Dim fn_Name : fn_Name = "fnButtonClick"
    fnButtonClick = False  
    'vObject.RefreshObject
    sClass = vObject.getroproperty("micclass")
    vClass = vObject.GetToProperty("TestObjName")
    ObjectType =  vObject.GetRoProperty("Class Name")
    'vClass = Replace(vClass,left(vClass,3),"")
    vObject.RefreshObject
    If vObject.Exist(10) Then
        ''vObject.Highlight
        If ObjectType <> "JavaEdit" Then
                vObject.click 5,5
        else
                vObject.click 5,5
        End If
        
        If Err.Number = 0 Then
           sMsg =  btnName & " Button Clicked | PASS"
            fnButtonClick = True
        Else     
             sMsg =  btnName & " No button clicked | FAIL"
        End If
    Else
        sMsg =  btnName & " No button clicked | FAIL"
    End If    
    
    If Instr(1,sMsg,"PASS") Then
     fnButtonClick = True
     fnUpdateExecutionDetailsXL "Button Clicked", btnName, "Pass", "N", "Y"
    ElseIf Instr(1,sMsg,"FAIL")Then
     fnUpdateExecutionDetailsXL "No button clicked", btnName, "Fail", "N", "Y"
    End If
        
    fnTraceLogs fn_Name & " | Button Clicked | " & sMsg,4,1
    On Error GoTo 0
    
End Function


Public Function Sendkey(ByVal sKey)

	Dim WSH
	Dim fn_Name : fn_Name = "Sendkey"
	Set WSH = CreateObject("WScript.Shell")
	WSH.SendKeys sKey 
	Set WSH = Nothing
	fnUpdateExecutionDetailsXL "Sendkeys", sKey, "Pass", "N", "Y"
	fnTraceLogs fn_Name & " | Sendkeys | " & sKey,4,1
	
End Function


Public Function fnMutlipleSendkey(ByVal sKey, ByVal iTimes)

	Dim WSH, i
	Dim fn_Name : fn_Name = "fnMutlipleSendkey"
	Set WSH = CreateObject("WScript.Shell")
	For i = 1 To iTimes Step 1
		WSH.SendKeys sKey 
		fnUpdateExecutionDetailsXL "Sendkeys", sKey, "Pass", "N", "Y"
		fnTraceLogs fn_Name & " | Sendkeys | " & sKey,4,1
	Next
	
	Set WSH = Nothing
	
End Function


'============================================================================================================================
'Function to close all Java Windows except the main 
'============================================================================================================================
Function fnCloseJavaWindowsBeforeTCRun()

    Dim objWindow : Set objWindow = Description.Create() : objWindow("to_class").Value="JavaWindow" 
    Dim SuggestedOptions, count, sWinName
    Dim fn_Name : fn_Name = "fnCloseJavaWindowsBeforeTCRun"
    Dim sMsg : sMsg = ""

    
    On Error Resume Next
    Err.Clear
    
    Set SuggestedOptions = Desktop.ChildObjects(objWindow)
    count = SuggestedOptions.Count
    
    If count > 0 Then
    	For i = 0  To count-1 Step 1
    		sWinName = Trim(SuggestedOptions(i).GetROProperty("title"))
    		If Not(Instr(1, sWinName,"ABS-Kern TEST <auf") > 0) Then
    			SuggestedOptions(i).Activate
    			SuggestedOptions(i).Close
    			fnUpdateExecutionDetailsXL "Close Java Window", sWinName, "Pass", "N", "N"
    			sMsg = sMsg  & sWinName & "; "
    		End If
    	Next
    End If
    
    Set SuggestedOptions = Nothing
    Set objWindow=Nothing
    
    If Err.Number = 0 Then
    	fnCloseJavaWindowsBeforeTCRun = True
    	fnTraceLogs fn_Name & " Java Windows Closed = " & sMsg,1,1
    Else
    	fnCloseJavaWindowsBeforeTCRun = False
    	fnTraceLogs fn_Name & " Java Windows Closed = None",1,1
    End If
    
    On Error Goto 0
                
End Function


'============================================================================================================================
'Function to close given Java Window
'============================================================================================================================
Public Function fnCloseGivenJavaWindow(ByRef vObject)
                
    fnCloseGivenJavaWindow = False
    Dim fn_Name : fn_Name = "fnCloseGivenJavaWindow"
    Dim sMsg : sMsg = ""
    
    Dim objWindow : Set objWindow=Description.Create() : objWindow("to_class").Value="JavaWindow" 
 
    If vObject.Exist(10) Then   
        vObject.Close
        If Err.Number = 0 Then
            CloseWindow = True
            sMsg = "Window closed | PASS"
        Else
			sMsg = "Window not closed | FAIL"
        End If
    Else
		sMsg = "Window not found | FAIL"
    End If
    
    If Instr(1, sMsg, "PASS") Then
    	fnUpdateExecutionDetailsXL "Close Java Window", "Yes", "Pass", "N", "N"
    	fnCloseGivenJavaWindow = True
    	fnTraceLogs fn_Name & " Java Windows Closed",1,1
    Else
    	fnUpdateExecutionDetailsXL "Close Java Window", "Yes", "Fail", "N", "N"
    	fnCloseGivenJavaWindow = True
    	fnTraceLogs fn_Name & " Java Windows not Closed",1,1
    End If    
    
    On Error GoTo 0    

End Function


Public Function fnHandleDialog(ByRef vObject, ByVal sValue)
	                                 
	Dim fn_Name : fn_Name = "fnHandleDialog"
    Dim sMsg : sMsg = "" 
    Dim ObjType
	fnHandleDialog = False    

	Err.Clear
	On Error Resume Next
    
   Set oButton=vObject.JavaButton("label:="&sValue)
   ObjType = Trim(oButton.GetROProperty("to_class"))
    
    If ObjType = "JavaButton" Then
        oButton.Click
    End If
    
    If Err.Number = 0 Then                
    	fnHandleDialog = True
        fnTraceLogs fn_Name & " | Button Clicked | " & sValue &" | PASS ",1,1
        fnUpdateExecutionDetailsXL "Click Dialog button", "Yes", "Pass", "N", "Y"
    Else
        fnTraceLogs fn_Name & " | Button not Clicked | " & sValue &" | FAIL ",1,1
        fnUpdateExecutionDetailsXL "Click Dialog button", "No", "Fail", "N", "Y"
    End If
     
    On Error GoTo 0
    
End Function

Public Function fnStaticTextClick(ByRef vObject,ByVal tabName, ByVal xvalue, ByVal yvalue)                                                                    
    On Error Resume Next
    Err.Clear
    Dim sMsg : sMsg = "" 
    Dim fn_Name : fn_Name = "fnStaticTextClick"
    
    FireEventObject = False
    sClass = vObject.GetRoProperty("micclass")
    vClass = vObject.GetToProperty("TestObjName")
    
    If vObject.Exist(10) Then
        vObject.Highlight
        vObject.click xvalue, yvalue
        If Err.Number = 0 Then 
            fnStaticTextClick = True        
            sMsg =  tabName & " Tab Clicked | PASS"
            
        Else            
            sMsg =  tabName & " Tab not Clicked | FAIL"
        End If
    Else        
        sMsg =  tabName & " No Tab exist | FAIL"
    End If
    
    If Instr(1,sMsg,"PASS") Then
     fnStaticTextClick = True
     fnUpdateExecutionDetailsXL "Tab Clicked", tabName, "Pass", "N", "Y"
    ElseIf Instr(1,sMsg,"FAIL")Then
     fnUpdateExecutionDetailsXL "No Tab clicked", tabName, "Fail", "N", "Y"
    End If
        
    fnTraceLogs fn_Name & " | Tab Clicked | " & sMsg,4,1
    On Error GoTo 0
    
End Function

Public Function fnTableSelectCell(ByRef vObject, ByVal row, ByVal col)                                                                    
    On Error Resume Next
    Err.Clear
    Dim sMsg : sMsg = "" 
    Dim fn_Name : fn_Name = "fnTableSelectCell"
    
    fnTableSelectCell = False
    sClass = vObject.GetRoProperty("micclass")
    vClass = vObject.GetToProperty("TestObjName")
    
    If vObject.Exist(10) Then
        vObject.Highlight
        vObject.SelectCell row, col
        If Err.Number = 0 Then 
            fnTableSelectCell = True        
            sMsg =  tabName & " Cell selected | PASS"
        Else            
            sMsg =  tabName & " No Cell selected | FAIL"
        End If
    Else        
        sMsg =  tabName & " No Cell exist | FAIL"
    End If
    
    If Instr(1,sMsg,"PASS") Then
     fnTableSelectCell = True
     fnUpdateExecutionDetailsXL "Tab Clicked", "", "Pass", "N", "Y"
    ElseIf Instr(1,sMsg,"FAIL")Then
     fnUpdateExecutionDetailsXL "No Tab clicked", "", "Fail", "N", "Y"
    End If
        
    fnTraceLogs fn_Name & " | Cell selected | " & sMsg,4,1
    On Error GoTo 0
    
End Function

Function fnRandomNumber(LengthOfRandomNumber)
	Dim sMaxVal : sMaxVal = ""
	Dim iLength : iLength = LengthOfRandomNumber

	'Find the maximum value for the given number of digits
	For iL = 1 to iLength
	sMaxVal = sMaxVal & "9"
	Next
	sMaxVal = Int(sMaxVal)

	'Find Random Value
	Randomize
	iTmp = Int((sMaxVal * Rnd) + 1)
	'Add Trailing Zeros if required
	iLen = Len(iTmp)
	fnRandomNumber = iTmp * (10 ^(iLength - iLen))

 End Function
 
 Function fnRC_Zusatz_Questions()                                
    On Error Resume Next
    Err.Clear
    RC_Zusatz_Questions = False
    
    Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag")
    RetVal = fnCheckObjectExist(objOP, "RC_Search_Contract.wndJwnd_Akte_Vertrag")
    If RetVal Then
    	Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaRadioButton("RC_Hatten_Sie")
    	RetVal = fnSelectRadioButton(objOP, "RC_Hatten_Sie")
    	If RetVal Then
    		Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaRadioButton("RC_BestehetFur")
    		RetVal = fnSelectRadioButton(objOP, "RC_BestehetFur")
    		If RetVal Then
    			Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaRadioButton("RC_Zusatz_erfult")
    			RetVal = fnSelectRadioButton(objOP, "RC_Zusatz_erfult")
    			If RetVal Then
    				Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaRadioButton("RC_Vorsteurab")
    				RetVal = fnSelectRadioButton(objOP, "RC_Vorsteurab")
    				If RetVal Then
    					Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaEdit("RC_Zusatz_Beruf")
    					RetVal = fnCheckEditable(objOP)
    					If RetVal Then
    						Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaEdit("RC_Zusatz_Beruf")
    						RetVal = fnEnterData(objOP, "")
							Sendkey "Sonstige"
							Sendkey "{DOWN}"
							Sendkey "~"
    						If RetVal Then
								fnRC_Zusatz_Questions = True
							Else
								fnRC_Zusatz_Questions = False
    						End If
    					End If
    				End If
    			End If
    		End If
    	End If
    End If
    
    If fnRC_Zusatz_Questions = True Then                
        sMsg = " Zustaz Questions answered | PASS"
    Else       
        sMsg = " Zustaz Questions not answered | Fail"
    End If
    	
		
End Function

Public Function fnCheckEditable(ByRef vObject)
                                                 
    On Error Resume Next
    Err.Clear
    
    fnCheckEditable = False
    
    Dim javaEdit 
    javaEdit=vObject.GetROProperty("editable")
    
    
    If javaEdit = 1 Then
                fnCheckEditable=True
                else
                fnCheckEditable=False
    End If
    
    If fnCheckEditable = True Then                
        sMsg = " JavaEdit is Editable | PASS"
    Else       
        sMsg = " JavaEdit is non editable | Fail"
    End If
    
    If Instr(1,sMsg,"PASS") Then
     fnCheckJavaEdit = True
     fnUpdateExecutionDetailsXL "javaEdit Feild is editable","", "Pass", "N", "Y"
    ElseIf Instr(1,sMsg,"FAIL")Then
     fnUpdateExecutionDetailsXL "javaEdit Feild is non editable","", "Fail", "N", "Y"
    End If
        
    fnTraceLogs fn_Name & " | Feild is editable | " & sMsg,4,1
     
    On Error GoTo 0
    
End Function

Public Function fnHandleDialogBoxButton(ByRef vObject, ByVal btnName)
	
	On Error Resume Next
    Err.Clear
    Dim fn_Name : fn_Name = "fnHandleDialogBoxButton"
    Dim sMsg : sMsg = ""
    fnHandleDialogBoxButton = True   
   
    If vObject.GetRoProperty("to_class") = "JavaWindow" Then
        Set oButton=vObject.JavaButton("label:="&btnName)
        oButton.Click
        If Err.Number <> 0 Then
           fnHandleDialogBoxButton = False
        End If
    End If
          
    If fnHandleDialogBoxButton Then
        sMsg = "Button Clicked | PASS"    
        fnTraceLogs fn_Name & " | Handle Dialog Box Button | " & btnName & " | " & sMsg,4,1    
        fnUpdateExecutionDetailsXL "Handle Dialog Box Button", btnName, "Pass", "N", "Y"
    Else
     sMsg = "Button not Clicked | FAIL"
        fnTraceLogs fn_Name & " | " & btnName & " | " & sMsg,4,1     
        fnUpdateExecutionDetailsXL "Handle Dialog Box Button", btnName, "Fail", "N", "Y"
    End If
    
    On Error GoTo 0
	
End Function


Public Function fnClickJavaObject(ByRef vObject,ByVal objectName, ByVal xvalue, ByVal yvalue)                                                                    
    On Error Resume Next
    Err.Clear
    Dim sMsg : sMsg = "" 
    Dim fn_Name : fn_Name = "fnClickJavaObject"
    
    FireEventObject = False
    sClass = vObject.GetRoProperty("micclass")
    vClass = vObject.GetToProperty("TestObjName")
    
    If vObject.Exist(10) Then
        vObject.Highlight
        vObject.click xvalue, yvalue
        If Err.Number = 0 Then 
            fnClickJavaObject = True        
            sMsg =  tabName & " Java Object Clicked | PASS"
        Else            
            sMsg =  tabName & "No Java Object Clicked | FAIL"
        End If
    Else        
        sMsg =  tabName & " No Java Object exist | FAIL"
    End If
    
    If Instr(1,sMsg,"PASS") Then
     fnClickJavaObject = True
     fnUpdateExecutionDetailsXL "Tab Clicked", objectName, "Pass", "N", "Y"
    ElseIf Instr(1,sMsg,"FAIL")Then
     fnUpdateExecutionDetailsXL "No Tab clicked", objectName, "Fail", "N", "Y"
    End If
        
    fnTraceLogs fn_Name & " | Java Object Clicked | " & sMsg,4,1
    On Error GoTo 0
    
End Function

