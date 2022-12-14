'#############################################################################################################################
'UTILITY FUNCTIONS - CONTAINS ALL FUNCTIONS TEST CASES FLOWS
'#############################################################################################################################

'============================================================================================================================
'Function search an existing person in RC
'============================================================================================================================
Function fnRC_Search_Existing_Person(ByVal input)
	
	Dim objOP
	Dim RetVal
	Dim errMsg
	Dim fnName : fnName = "fnRC_Search_Existing_Person"
	errMsg = "PASS"
	
	
	Set objOP = JavaWindow("RC_Search_Contract.wndjwnd_ABSKern")
	RetVal = fnCheckObjectExist(objOP, "Main Page")
	If RetVal Then
		Sendkey "%p"
		Wait 1
		'Select Legal Person
		If (input.item("Legal_Person")) = "YES" Then
			Set objOP = JavaWindow("Person suchen <auf DTGEP45>").JavaRadioButton("Legal_Person")
			If objOP.GetROProperty("value") <> "1" Then			
				RetVal = fnSelectRadioButton(objOP, "Legal_Person")
				If RetVal Then
					Set objOP = JavaWindow("Person suchen <auf DTGEP45>").JavaEdit("RC_PersonFirstName")
					RetVal = fnEnterData(objOP, input.item("Person_FirstName"))
				End If				
			End If	
		Else
		'Select natural person
			Set objOP = JavaWindow("Person suchen <auf DTGEP45>").JavaRadioButton("RC_Naturliche_Person")
			If objOP.GetROProperty("value") <> "1" Then			
				RetVal = fnSelectRadioButton(objOP, "RC_Naturliche_Person")
			Else
				If RetVal Then
					Set objOP = JavaWindow("Person suchen <auf DTGEP45>").JavaEdit("RC_PersonFirstName")
					RetVal = fnEnterData(objOP, input.item("Person_FirstName"))
					If RetVal Then
						Set objOP = JavaWindow("Person suchen <auf DTGEP45>").JavaEdit("RC_PersonSecondName")
						RetVal = fnEnterData(objOP, input.item("Person_SecondName"))
						
						If (input.item("Person_DOB")) <> "" Then
							Set objOP = JavaWindow("Sudipta_Person_suchen").JavaEdit("Geburtsdatum")
							RetVal = fnEnterData(objOP, input.item("Person_DOB"))
							wait 1
						Else
							errMsg = "No value for Person DOB | Fail"
						End If
					End If
				End If				
			End If			
		End If
		
		If RetVal Then
			Set objOP = JavaWindow("Person suchen <auf DTGEP45>").JavaButton("RC_Person_Search")
			RetVal = fnButtonClick(objOP, "Suchen")
			If RetVal Then
				Set objOP = JavaWindow("Sudipta_Person_suchen")
				Set desc = Description.Create
				desc("to_class").Value = "JavaWindow"
				desc("title").Value = "Ereignisanzeige"
				Set coll = objOP.ChildObjects(desc)

				If coll.Count > 0 Then
					fnRC_Search_Existing_Person = "False"
					errMsg = "Invalid Person Name | Exit"
					RetVal = fnHandleDialog (coll(coll.Count-1), "Schließen")
					If RetVal Then
						errMsg = "Incorrect Person Name | Exit"
						fnRC_Search_Existing_Person = "False"
					End If
					
				Else
					Set objOP = JavaWindow("Person suchen <auf DTGEP45>")
					Set desc1 = Description.Create
					desc1("to_class").Value = "JavaEdit"
					desc1("attached text").Value = "Name/Adresse"
					Set coll = objOP.ChildObjects(desc1)
					If coll.Count > 0 Then			
						'svalue = coll(1).GetRoProperty("value")
						'If InStr(1, svalue, input.item("Person_FirstName")) > 0 Then
'							Set objOP = JavaWindow("Person suchen <auf DTGEP45>").JavaButton("RC_Person_OK")
							RetVal = fnButtonClick(objOP, "OK")
							fnRC_Search_Existing_Person = "True"
'						Else
'							errMsg = "Person Not Found | Exit"
'							fnRC_Search_Existing_Person = "False"
'						End If
					Else
						errMsg = "Person Not Found | Exit"
						fnRC_Search_Existing_Person = "False"
					End If
					
				End If
			Else
				errMsg = "Person search button not Clicked | Exit"
				fnRC_Search_Existing_Person = "False"
			End If
				
		End If
		
	Else
		errMsg = "ABSI application is not launched | Fail"
		fnRC_Search_Existing_Person = "False"		
	End If
	
	
	If fnRC_Search_Existing_Person = "True" Then
		fnTraceLogs "Person Search = " & input("Person_FirstName") &" "& input("Person_SecondName") & " | " & errMsg,1,1		
		fnUpdateExecutionDetailsXL "Person Search", input("Person_FirstName") &" "& input("Person_SecondName"), "Pass", "Y", "Y"
	Else
		fnTraceLogs "Person Search = " & input("Person_FirstName") &" "& input("Person_SecondName") & " | " & errMsg,1,1		
		fnUpdateExecutionDetailsXL "Person Search", input("Person_FirstName") &" "& input("Person_SecondName"), "Fail", "Y", "Y"	
	End If
			
End Function


Function fnRC_Create_Person(ByVal input)

	Dim objOP
	Dim RetVal
	Dim errMsg
	Dim fnName : fnName = "fnRC_Create_Person"
	errMsg = "PASS"
	
	Set objOP = JavaWindow("RC_Search_Contract.wndjwnd_ABSKern")
	RetVal = fnCheckObjectExist(objOP, "RC_Search_Contract.wndjwnd_ABSKern")
	If RetVal Then
		Sendkey "%p"
		wait 3
		If ucase(input.item("New_Person")) = "YES" Then					
			If ucase(input.item("Legal_Person")) = "YES" Then 
				Set objOP = JavaWindow("Person suchen <auf DTGEP45>").JavaRadioButton("Legal_Person")	'select legal person radiobutton
						RetVal = fnSelectRadioButton(objOP, "Legal_Person")
						If RetVal Then
							Set objOP = JavaWindow("Person suchen <auf DTGEP45>").JavaEdit("RC_PersonFirstName")
							RetVal = fnEnterData(objOP, "")
							RetVal = fnEnterData(objOP, input.item("Person_FirstName"))
							If RetVal Then
								Set objOP = JavaWindow("Person suchen <auf DTGEP45>").JavaButton("RC_Person_Search")
								RetVal = fnButtonClick(objOP, "RC_Person_Search")
								If RetVal Then
									Set objOP = JavaWindow("Person suchen <auf DTGEP45>").JavaButton("RC_New_Person")
									RetVal = fnButtonClick(objOP, "RC_New_Person")
									If ucase(input.item("Legal_Person")) = "YES" Then
										Set objOP = JavaWindow("Akte Juristische Person").JavaButton("Zuordnen")
										RetVal = fnButtonClick(objOP, "Zuordnen")
										If RetVal Then
											Set objOP = JavaWindow("Akte Juristische Person").JavaWindow("Betreuer/Vermittler suchen")
											RetVal = fnCheckObjectExist(objOP, "Betreuer/Vermittler suchen")
											If RetVal Then
												Set objOP = JavaWindow("Akte Juristische Person").JavaWindow("Betreuer/Vermittler suchen").JavaEdit("RC_Person_Vermittler")
												RetVal = fnEnterData(objOP, input.item("VermittlerNr"))
												If RetVal Then
													Set objOP = JavaWindow("Akte Juristische Person").JavaWindow("Betreuer/Vermittler suchen").JavaButton("RC_Vermittler_Suchen")
													RetVal = fnButtonClick(objOP, "RC_Vermittler_Suchen")
												If RetVal Then
													Set objOP = JavaWindow("Akte Juristische Person").JavaWindow("Betreuer/Vermittler suchen").JavaButton("RC_Vermitler_OK")
													RetVal = fnButtonClick(objOP, "RC_Vermitler_OK")
													If RetVal Then
														Set objOP = JavaWindow("Akte Juristische Person").JavaButton("RC_Person_Address_Andern")
														RetVal = fnButtonClick(objOP, "RC_Person_Address_Andern")
														If RetVal Then
															Set objOP = JavaWindow("Akte Juristische Person").JavaWindow("Adresse bearbeiten").JavaEdit("RC_Person_Pincode")
															RetVal = fnEnterData(objOP, input.item("Person_Pincode"))
															If RetVal Then
																Set objOP = JavaWindow("Akte Juristische Person").JavaWindow("Adresse bearbeiten").JavaButton("RC_Pincode_Search")
																RetVal = fnButtonClick(objOP, "RC_Pincode_Search")
																If RetVal Then
																	Set objOP = JavaWindow("Akte Juristische Person").JavaWindow("Adresse bearbeiten").JavaWindow("Orts- und Straßenverzeichnis")
																	RetVal = fnCloseGivenJavaWindow(objOP)															
																If RetVal Then
																	Set objOP = JavaWindow("Akte Juristische Person").JavaWindow("Adresse bearbeiten").JavaEdit("RC_Person_Zusatz")
																	RetVal = fnEnterData(objOP, input.item("Person_CityName"))
																	If RetVal Then
																		Set objOP = JavaWindow("Akte Juristische Person").JavaWindow("Adresse bearbeiten").JavaEdit("RC_HouseNr")
																		RetVal = fnEnterData(objOP, "74")
																		If RetVal Then
																			Set objOP = JavaWindow("Akte Juristische Person").JavaWindow("Adresse bearbeiten").JavaButton("RC_Address_OK")
																			RetVal = fnButtonClick(objOP, "RC_Address_OK")
																			 If RetVal Then
																			 	Set objOP = JavaWindow("Akte Juristische Person").JavaWindow("Adresse bearbeiten").JavaWindow("Ereignisanzeige")
																			 	'RetVal = fnCheckObjectExist(objOP, "Ereignisanzeige")
																			 	'JavaWindow("Akte Juristische Person").JavaWindow("Adresse bearbeiten").JavaWindow("Ereignisanzeige").JavaButton("RC_Popup_After_Person_Address").Click
																			 	If RetVal Then
																			 		Set objOP = JavaWindow("Akte Juristische Person").JavaStaticText("RC_Person_Zusatz")
																			 		RetVal = fnStaticTextClick(objOP, "RC_Person_Zusatz", "20","7")
																			 		If RetVal Then
																			 			Set objOP = JavaWindow("Akte Juristische Person").JavaButton("RC_Person_Zusatz_Hinzufugen")
																			 			RetVal = fnButtonClick(objOP, "RC_Person_Zusatz_Hinzufugen")
																			 			If RetVal Then
																			 				Set objOP = JavaWindow("Akte Juristische Person").JavaTable("RC_Person_Zusatz_JavaTable")
																			 				RetVal = fnTableSelectCell(objOP,"0","Art")
																			 				If RetVal Then
																			 					If  ucase(input.item("Legal_Person")) = "YES" Then
																									Sendkey "^a"
																									Sendkey "{DEL}"
																									Sendkey "Firmenbuchauszug"
																									Sendkey "{DOWN}"
																									Sendkey "~"
																									Sendkey "{TAB}"
																									Sendkey "C"
																									Sendkey "{TAB}"
																									strTemp = fnRandomNumber(5)
																									Sendkey strTemp
																									Sendkey "{TAB}"
																									Sendkey Date
																									Sendkey "{TAB}"
																									Sendkey "Berlin"
																									wait 2
																								else
																									strTemp = fnRandomNumber(5)
																									Sendkey strTemp
																									Sendkey "{TAB}"
																									Sendkey "C"
																									Sendkey "{TAB}"
																									Sendkey Date
																									Sendkey "{TAB}"
																									Sendkey "Berlin"
																									wait 2
																								End If
																								Set objOP = JavaWindow("Akte Juristische Person").JavaStaticText("RC_BAnkKK_")
																								RetVal = fnStaticTextClick(objOP,"RC_BAnkKK_", "26","6")
																								If RetVal Then
																									Set objOP = JavaWindow("Akte Juristische Person").JavaButton("RC_Bank_KK_Hinzufügen")
																									RetVal = fnButtonClick(objOP, "RC_Bank_KK_Hinzufügen")
																									If RetVal Then
																										Set objOP = JavaWindow("Akte Juristische Person").JavaTable("RC_Person_Zusatz_JavaTable")
																										RetVal = fnTableSelectCell(objOP,"0","BIC")
																										Sendkey "BFSWDE33XXX"
																										Sendkey "{TAB}"
																										Sendkey "DE23370205000008090100"
																										Sendkey "^S"
																										fnUpdateExecutionDetailsXL "Person Created", input.item("Person_FirstName"), "Pass", "Y", "Y"
																										If RetVal Then
																											Set objOP = JavaWindow("Akte Juristische Person")
 																											Call fnCloseGivenJavaWindow(objOP)
 																											wait 2
																											If RetVal Then
																												Set objOP = JavaWindow("Akte Juristische Person").JavaWindow("RC_Achtung")
																												RetVal = fnClickDialogBoxButton(objOP,"Ja")
																												wait 1
																												If RetVal Then
																													fnUpdateExecutionDetailsXL "Save and close", "", "Pass", "Y", "Y"
																													fnRC_Create_Person = "True"
																												Else
																													fnUpdateExecutionDetailsXL "Save and close", "", "Fail", "Y", "Y"
																													errMsg = "Legal Person not created|Exit"
																													fnRC_Create_Person = "False"
																												End If																							
																											End If
																										End If
																									Else
																										fnUpdateExecutionDetailsXL "Person Created", input.item("Person_FirstName") & input.item("Person_SecondName"), "Fail", "Y", "Y"
																					 				End If
																					 			End If
																					 		End If
																					 	End If
																					 End If
																				End If															
																			End If
																		End If
																	End If												
																End If
															End If
														End If
													End If
												End If
											End If
										End If
									End If
								End If
							End If
						End If
					End If
				End If
			Else
				'For Natural person
					Set objOP = JavaWindow("Person suchen <auf DTGEP45>").JavaRadioButton("RC_Naturliche_Person")	'select legal person radiobutton
						RetVal = fnSelectRadioButton(objOP, "RC_Naturliche_Person")
						If RetVal Then
							Set objOP = JavaWindow("Person suchen <auf DTGEP45>").JavaEdit("RC_PersonFirstName")
							RetVal = fnEnterData(objOP, input.item("Person_FirstName"))
							If RetVal Then
								Set objOP = JavaWindow("Person suchen <auf DTGEP45>").JavaEdit("RC_PersonSecondName")
								RetVal = fnEnterData(objOP, input.item("Person_SecondName"))
								If RetVal Then
									If (input.item("Person_DOB")) <> "" Then
									  Set objOP = JavaWindow("Sudipta_Person_suchen").JavaEdit("Geburtsdatum")
									  RetVal = fnEnterData(objOP, input.item("Person_DOB"))
									  wait 1
									  If RetVal Then
									  	Set objOP = JavaWindow("Person suchen <auf DTGEP45>").JavaButton("RC_Person_Search")
										RetVal = fnButtonClick(objOP, "RC_Person_Search")
										If RetVal Then
											Set objOP = JavaWindow("Person suchen <auf DTGEP45>").JavaButton("RC_New_Person")
											RetVal = fnButtonClick(objOP, "RC_New_Person")
											If RetVal Then
												Set objOP = JavaWindow("Akte Natürliche Person").JavaEdit("RC_Person_DOB")
									  			RetVal = fnEnterData(objOP, input.item("Person_DOB"))
									  				If RetVal Then
										  				If input.item("Person_Gender") <> "Female" Then
										  					Set objOP = JavaWindow("Akte Natürliche Person").JavaRadioButton("RC_Person_Gender")
										  					RetVal = fnSelectRadioButton(objOP, "RC_Person_Gender")
										  				Else
										  					Set objOP = JavaWindow("Akte Natürliche Person").JavaRadioButton("Geschlecht")
										  					RetVal = fnSelectRadioButton(objOP, "Geschlecht")
										  				End If
									  						If RetVal Then
											  					If input.item("Akad_Title") <> "" Then
											  						Set objOP = JavaWindow("Akte Natürliche Person").JavaEdit("RC_Akad_Titel")
											  						RetVal = fnEnterData(objOP, input.item("Akad_Title"))
											  						If RetVal Then
											  							If input.item("Anredezusatz") <> "" Then
													  						Set objOP = JavaWindow("Akte Natürliche Person").JavaEdit("RC_Anredezusatz")
													  						RetVal = fnEnterData(objOP, input.item("Anredezusatz"))
													  						If RetVal Then
													  							If input.item("Person_Zusatz") <> "" Then
															  						Set objOP = JavaWindow("Akte Natürliche Person").JavaEdit("Person_Zusatz")
															  						RetVal = fnEnterData(objOP, input.item("Person_Zusatz"))
															  						If RetVal Then
															  							Set objOP = JavaWindow("Akte Natürliche Person").JavaButton("RC_Person_Kundenbetr")
											  											RetVal = fnButtonClick(objOP, "RC_Person_Kundenbetr")
											  											If RetVal Then
											  												Set objOP = JavaWindow("Akte Natürliche Person").JavaWindow("Betreuer/Vermittler suchen")
																							RetVal = fnCheckObjectExist(objOP, "Betreuer/Vermittler suchen")
																							If RetVal Then
																								Set objOP = JavaWindow("Akte Natürliche Person").JavaWindow("Betreuer/Vermittler suchen").JavaEdit("RC_Person_Vermittler")
																								If RetVal Then
																									Set objOP = JavaWindow("Akte Natürliche Person").JavaWindow("Betreuer/Vermittler suchen").JavaButton("RC_Vermittler_Suchen")
																									RetVal = fnButtonClick(objOP, "RC_Vermittler_Suchen")
																									If RetVal Then
																										Set objOP = JavaWindow("Akte Natürliche Person").JavaWindow("Betreuer/Vermittler suchen").JavaButton("RC_Vermitler_OK")
																										RetVal = fnButtonClick(objOP, "RC_Vermitler_OK")
																										wait 3
																										If RetVal Then
																											Set objOP = JavaWindow("Akte Natürliche Person").JavaButton("RC_Person_Address_Andern")
																											RetVal = fnButtonClick(objOP, "RC_Person_Address_Andern")
																											wait 2
																											If RetVal Then
																												Set objOP = JavaWindow("Akte Natürliche Person").JavaWindow("Adresse bearbeiten").JavaEdit("RC_Person_Pincode")
																												RetVal = fnEnterData(objOP, input.item("Person_Pincode"))
																												If RetVal Then
																													Set objOP = JavaWindow("Akte Natürliche Person").JavaWindow("Adresse bearbeiten").JavaButton("RC_Pincode_Search")
																													RetVal = fnButtonClick(objOP, "RC_Pincode_Search")
																												If RetVal Then
																													Set objOP = JavaWindow("Akte Natürliche Person").JavaWindow("Adresse bearbeiten").JavaWindow("Orts- und Straßenverzeichnis")
																													RetVal = fnCloseGivenJavaWindow(objOP)
																													If RetVal Then
																														Set objOP = JavaWindow("Akte Natürliche Person").JavaWindow("Adresse bearbeiten").JavaEdit("RC_Person_Zusatz")
																														RetVal = fnEnterData(objOP, input.item("Person_CityName"))
																														If RetVal Then
																															Set objOP = JavaWindow("Akte Natürliche Person").JavaWindow("Adresse bearbeiten").JavaEdit("RC_HouseNr")
																															RetVal = fnEnterData(objOP, "74")
																															If RetVal Then
																																Set objOP = JavaWindow("Akte Natürliche Person").JavaWindow("Adresse bearbeiten").JavaButton("RC_Address_OK")
																																RetVal = fnButtonClick(objOP, "RC_Address_OK")
																																If RetVal Then
																	 															Set objOP = JavaWindow("Akte Natürliche Person").JavaStaticText("RC_Person_Zusatz")
																	 															RetVal = fnStaticTextClick(objOP, "RC_Person_Zusatz", "20","7")
																	 															If RetVal Then
																	 																Set objOP = JavaWindow("Akte Natürliche Person").JavaButton("RC_Person_Zusatz_Hinzufugen")
																	 																RetVal = fnButtonClick(objOP, "RC_Person_Zusatz_Hinzufugen")
																	 																If RetVal Then
																	 																	Set objOP = JavaWindow("Akte Natürliche Person").JavaTable("RC_Person_Zusatz_JavaTable")
																	 																	RetVal = fnTableSelectCell(objOP , "0","Ausweis Nr.")
																	 																	strTemp = fnRandomNumber(5)
																																		Sendkey strTemp
																																		Sendkey "{TAB}"
																																		Sendkey "C"
																																		Sendkey "{TAB}"
																																		Sendkey Date
																																		Sendkey "{TAB}"
																																		Sendkey "Berlin"
																																		wait 2
																	 																	If RetVal Then
																	 																		Set objOP = JavaWindow("Akte Natürliche Person").JavaStaticText("RC_BAnkKK_")
																	 																		RetVal = fnStaticTextClick(objOP, "RC_BAnkKK_", "26","6")
																	 																		If RetVal Then
																	 																			Set objOp = JavaWindow("Akte Natürliche Person").JavaButton("RC_Bank_KK_Hinzufügen")
																	 																			RetVal = fnButtonClick(objOP, "RC_Bank_KK_Hinzufügen")
																	 																			If RetVal Then
																	 																				Set objOp = JavaWindow("Akte Natürliche Person").JavaTable("RC_Person_Zusatz_JavaTable")
																	 																				RetVal = fnTableSelectCell(objOP , "0","BIC")
																	 																				Sendkey "BFSWDE33XXX"
																																					Sendkey "{TAB}"
																																					Sendkey "DE23370205000008090100"
																	 																				Sendkey "^S"
																	 																				fnUpdateExecutionDetailsXL "Person Created", input.item("Person_FirstName") & input.item("Person_SecondName"), "Pass", "Y", "Y"
																	 																				wait 1
																	 																				If RetVal Then
																	 																					Set objOP = JavaWindow("Akte Natürliche Person")
  																																						Call fnCloseGivenJavaWindow(objOP)
  																																						wait 2
																	 																					If RetVal Then
																	 																						Set objOP = JavaWindow("Akte Natürliche Person").JavaWindow("RC_Achtung")
	    																																					RetVal = fnClickDialogBoxButton(objOP,"Ja")
	    																																					If RetVal Then
	    																																						fnUpdateExecutionDetailsXL "Save and close", "", "Pass", "Y", "Y"
	    																																						fnRC_Create_Person = "True"
	    																																					Else
	    																																						fnUpdateExecutionDetailsXL "Save and close", "", "Fail", "Y", "Y"
	    																																						fnRC_Create_Person = "False"
	    																																					End If
																	 																					Else
																	 																						errMsg = "Natural Person not created|Exit"
																	 																						fnRC_Create_Person = "False"
																	 																					End If
																 																					End If
																	 																			Else
																	 																				fnUpdateExecutionDetailsXL "Person Created", input.item("Person_FirstName") & input.item("Person_SecondName"), "Fail", "Y", "Y"
																	 																			End If
																	 																		End If
																	 																	End If
																	 																End If
																	 															End If
																	 														End If
																	 													End If
																 													End If		
																												End If
																											End If
																										End If
																									End If
																								End If
																							End If
																						End If
										  											End If
														  						End If
														  					End If
												  						End If
												  					End If
										  						End If
										  					End If
										  				End If
													End If
												End If
											End If
									 	 End If
									End If
								End If
							End If
						End If
					End IF		
				End If
			Else
				Call fnRC_Search_Existing_Person()
			End If
		Else
			errMsg = "ABSI application is not launched | Fail"
			fnRC_Create_Person = "False"
		End If		
		
		If fnRC_Create_Person = "True" Then
			fnTraceLogs "Person Create = " & input("Person_FirstName") &" "& input("Person_SecondName") & " | " & errMsg,1,1		
'			fnUpdateExecutionDetailsXL "Person Create", input("Person_FirstName") &" "& input("Person_SecondName"), "Pass", "Y", "Y"
		Else
			fnTraceLogs "Person Create = " & input("Person_FirstName") &" "& input("Person_SecondName") & " | " & errMsg,1,1		
'			fnUpdateExecutionDetailsXL "Person Create", input("Person_FirstName") &" "& input("Person_SecondName"), "Fail", "Y", "Y"	
		End If
		
End Function

Function fnRC_Edit_Contract()

	Set objOP = JavaWindow("RC_Edit_Contract.wndJavaWindow0")
	RetVal = fnCheckObjectExist(objOP, "RC_Edit_Contract.wndJavaWindow0")
	If RetVal Then
		SendKey "{F7}"
		wait 2
		Set objOP = JavaWindow("RC_Edit_Contract.wndJavaWindow0").JavaWindow("RC_Edit_Contract.wndjwnd_Vertragsersatz")
		RetVal = fnCheckObjectExist(objOP, "RC_Edit_Contract.wndjwnd_Vertragsersatz")
		If RetVal Then
			fnRC_Edit_Contract = "True"
		Else
			fnRC_Edit_Contract = "False"
			errMsg = "Contract not opened in edit mode | Fail"
		End If
	Else
		errMsg = "Error|Contract not openened in application|Exit"
		fnRC_Edit_Contract = "False"
	End If
	
	If fnRC_Create_Person = "True" Then
		fnTraceLogs "Edit Contract = " & " | " & errMsg,1,1		
'			fnUpdateExecutionDetailsXL "Edit Contract", input("Person_FirstName") &" "& input("Person_SecondName"), "Pass", "Y", "Y"
	Else
		fnTraceLogs "Edit Contract = " & " | " & errMsg,1,1		
'			fnUpdateExecutionDetailsXL "Person Create", input("Person_FirstName") &" "& input("Person_SecondName"), "Fail", "Y", "Y"	
	End If
			
End Function


Function fnRC_Search_Contract(input)

	
	Set objOP = JavaWindow("RC_Search_Contract.wndjwnd_ABSKern")
	RetVal = fnCheckObjectExist(objOP, "RC_Search_Contract.wndjwnd_ABSKern")
	If RetVal Then
		SendKey "%v"
		wait 2
		Set objOP = JavaWindow("RC_Search_Contract.wndjwnd_VertragSuchen")
		RetVal = fnCheckObjectExist(objOP, "RC_Search_Contract.wndjwnd_VertragSuchen")
		If RetVal Then
			If input.item("Policy_Number") <> "" Then
				Set objOP = JavaWindow("RC_Search_Contract.wndjwnd_VertragSuchen").JavaEdit("RC_Search_Contract.edtjedt_PolicyNummer")
				RetVal = fnEnterData(objOP, input.item("Policy_Number"))
				If RetVal Then
					Set objOP = JavaWindow("RC_Search_Contract.wndjwnd_VertragSuchen").JavaButton("RC_Search_Contract.btnjbtn_Suchen")
					RetVal = fnButtonClick(objOP, "RC_Search_Contract.btnjbtn_Suchen")
					If RetVal Then
						Set objOP = JavaWindow("RC_Search_Contract.wndjwnd_VertragSuchen").JavaTable("RC_Search_Contract.tbljtbl_Policynummer")
						objOP.SelectRow (input.item("SelectRow_PolicyNumber"))
						If RetVal Then
							Set objOP = JavaWindow("RC_Search_Contract.wndjwnd_VertragSuchen").JavaButton("RC_Search_Contract.btnjbtn_OK")
							RetVal = fnButtonClick(objOP, "RC_Search_Contract.btnjbtn_OK")
							If RetVal Then
								Set objOP = JavaWindow("RC_Search_Contract.wndjwnd_VertragSuchen").JavaWindow("RC_Search_Contract.wndjwnd_Aktenauswahl")
								RetVal = fnCheckObjectExist(objOP, "RC_Search_Contract.wndjwnd_Aktenauswahl")
								If RetVal Then
									Set objOP = JavaWindow("RC_Search_Contract.wndjwnd_VertragSuchen").JavaWindow("RC_Search_Contract.wndjwnd_Aktenauswahl").JavaButton("RC_Search_Contract.btnjbtn_OK_Aktenauswahl")
									RetVal = fnButtonClick(objOP, "RC_Search_Contract.btnjbtn_OK_Aktenauswahl")
									wait 8
									If RetVal Then
										Set objOP = JavaWindow("RC_Edit_Contract.wndJavaWindow0")
										RetVal = fnCheckObjectExist(objOP, "RC_Edit_Contract.wndJavaWindow0")
										If RetVal Then
											fnRC_Search_Contract = "True"
										Else
											fnRC_Search_Contract = "False"
										End If
									End If
								End If
							End If
						End If
					End If
				End If
			End If
		Else
			errMsg = "No value for Policy Number | Fail"
		End If
	Else
			fnRC_Search_Contract = "Error|ABSI application is not launched|Exit"
	End If
	
	If fnRC_Search_Existing_Person = "True" Then
		fnTraceLogs "Contract Search = " & input("Type@jedt_PolicyNummer") & " | " & errMsg,1,1		
		fnUpdateExecutionDetailsXL "Contract Search", input("Policy_Number"), "Pass", "Y", "Y"
	Else
		fnTraceLogs "Contract Search = " & input("Type@jedt_PolicyNummer") & " | " & errMsg,1,1		
		fnUpdateExecutionDetailsXL "Contract Search", input("Policy_Number"), "Fail", "Y", "Y"	
	End If
	
End Function


Function fnRC_Contract_Creation(input)

Dim dict
Set dict = CreateObject("Scripting.Dictionary")
dict.Add "Person_FirstName", "TestFour" 
dict.Add "Person_SecondName", "Test"
dict.Add "Legal_Person", "NO"
dict.Add "Person_DOB", ""	

Retval = fnRC_Search_Existing_Person(dict)	'First call person search function then create contract for that person, verify the agent no as per the mendant 
If RetVal Then
		Environment("strKennzeichenNr") =fnRandomNumber(4)
		Environment("strVBANr") =fnRandomNumber(5)
		'If JavaWindow("Akte Natürliche Person").GetROProperty("enabled") = 1  Then
		wait 2
		SendKey "%b"
		wait 2
		Sendkey "~"
		wait 5
		Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaWindow("Produktauswahl")
		RetVal = fnCheckObjectExist(objOP, "Produktauswahl")
		If RetVal Then
			Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaWindow("Produktauswahl").JavaEdit("RC_Contract_Mandate")
			RetVal = fnEnterData(objOP, input.item("Mandate"))
			If RetVal Then
				Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaWindow("Produktauswahl").JavaTable("RC_Mandate_JavaTable")
				n = objOP.GetROProperty("rows")
				For i = 0 TO n-1
					str_name = objOP.GetCellData (i,1)
					If str_name = dict3.item("Policy") Then
						objOP.ClickCell i,2
						Exit for
					End If
				Next
				If RetVal Then
					Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaWindow("Produktauswahl").JavaButton("RC_Product_OK")
					RetVal = fnButtonClick(objOP, "RC_Product_OK")
					wait 1
					If RetVal Then
						Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaWindow("Produktauswahl").JavaWindow("Ereignisanzeige")
						RetVal = fnCheckObjectExist(objOP, "Ereignisanzeige")
						'take screenshot of the Ereignisanzeige window
						fnRC_Contract_Creation = "False"
						Exit Function
					Else
						Select Case input.item("NewBusiness_ProcessType")
							Case "D03"
								Sendkey "~"
							Case "D04"
								Sendkey "{DOWN}"
								Sendkey "~"
							Case "D05"
								Sendkey "{DOWN}"
								Sendkey "{DOWN}"
								Sendkey "~"
						End Select
						Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag")
						RetVal = fnCheckObjectExist(objOP, "RC_Search_Contract.wndJwnd_Akte_Vertrag")
						If RetVal Then
							Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaButton("RC_KFZAkte_ObjectDet_Hinzufügen")
							RetVal = fnButtonClick(objOP, "RC_KFZAkte_ObjectDet_Hinzufügen")
							wait 1
							If RetVal Then
								set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaWindow("Objektartenauswahl").JavaTable("RC_ObjectArt_KFZAnlegen")
								n = objOP.GetROProperty("rows")
								For i = 0 TO n-1
									str_name = objOP.GetCellData (Cint(i),0)
									If instr(1,str_name,"KFZ anlegen") > 0 Then
										set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaWindow("Objektartenauswahl").JavaButton("RC_ObjectArt_KFZanlegen_OK")
										RetVal = fnButtonClick(objOP, "RC_ObjectArt_KFZanlegen_OK")
										wait 5
										Exit for
									End If
								Next
								If RetVal Then
									Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaWindow("KFZ - Typenauswahl")
									RetVal = fnCheckObjectExist(objOP, "KFZ - Typenauswahl")
									If RetVal Then
										Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaWindow("KFZ - Typenauswahl").JavaEdit("RC_Marke")
										RetVal = fnEnterData(objOP, input.item("Marke"))
										If RetVal Then
											Sendkey "{DOWN}"
											Sendkey "~"
											strmodell =fnRandomNumber(1)
											Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaWindow("KFZ - Typenauswahl").JavaEdit("RC_Modell")
											RetVal = fnEnterData(objOP, "")
											If RetVal Then
												For i = 0 To strmodell
												Sendkey "{DOWN}"			
												Next
												Sendkey "~"
												Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaWindow("KFZ - Typenauswahl").JavaButton("RC_Übernehmen")
												RetVal = fnButtonClick(objOP, "RC_Übernehmen")
												wait 5
												If RetVal Then
													Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaEdit("RC_KennzeichenNr")
													RetVal = fnEnterData(objOP, "")
													Sendkey "B-FG "&Environment("strKennzeichenNr")
													wait 1
													If RetVal Then
														Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaEdit("RC_FahrgestellNr")
														RetVal = fnEnterData(objOP, "")
														If RetVal Then
															Sendkey (input.item("FahrgestellNr"))
															wait 2
															Sendkey ""
															Sendkey "{TAB}"
														'	Sendkey (input.item("FZG_ART"))
														'	wait 3
															Sendkey "{TAB}"
															Sendkey (input.item("Verwend"))
															wait 3
															Sendkey "{DOWN}"
															Sendkey "~"
															wait 1
															If RetVal Then
																Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag")
																RetVal = fnCheckObjectExist(objOP, "RC_Search_Contract.wndJwnd_Akte_Vertrag")
																If RetVal Then
																	Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaEdit("RC_Object_Stamm_ZulässigeGesamtmasse")
																	'RetVal = fnCheckEditable(objOP, "RC_Object_Stamm_ZulässigeGesamtmasse")
																	If RetVal Then
																		Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaEdit("RC_Object_Stamm_ZulässigeGesamtmasse")
																		RetVal = fnEnterData(objOP, input.item("ZulässigeGesamtmasse_Kg"))
																		wait 2
																		If RetVal Then
																			Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaEdit("RC_Behörde")
																			RetVal = fnEnterData(objOP, input.item("Behorde"))
																			wait 3
																			If RetVal Then
																				Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaEdit("E_VBA_NR")
																				RetVal = fnEnterData(objOP, "VD"&Environment("strVBANr"))
																				If Retval Then
																					Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaEdit("RC_Erstzulass_am_Date")
																					RetVal = fnEnterData(objOP, Date)
																					If RetVal Then
																						Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaEdit("RC_Erstzulassung_VN_Date")
																						RetVal = fnEnterData(objOP, Date)
																						If RetVal Then
																							Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaStaticText("RC_Object_Detail")
																							RetVal = fnStaticTextClick(objOP,"RC_BAnkKK_", "20","13")
																							If RetVal Then
																								Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaTable("RC_ObjectDetail_JavaTable")
																								RetVal = fnTableSelectCell(objOP,"0","Datum")
																								If RetVal Then
																									Sendkey Date
																									Sendkey "{TAB}"
																									Sendkey (input.item("KilometerStand"))
																									wait 2
																									Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaTable("RC_ObjectDetail_JavaTable")
																									RetVal = fnTableSelectCell(objOP,"0","Kilometerstandsgrund")
																									wait 2
																									If RetVal Then
																										Sendkey (input.item("KilometerStandGrund"))
																										Sendkey "{DOWN}"
																										Sendkey "~"
																										Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaStaticText("RC_Contract_Amendment_Flow.sttjstt_Produkte_Tab")
																										RetVal = fnStaticTextClick(objOP,"RC_Contract_Amendment_Flow.sttjstt_Produkte_Tab", "25","13")
																										If RetVal Then
																											Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaStaticText("RC_Object_Detail")
																											RetVal = fnStaticTextClick(objOP,"RC_Object_Detail", "20","13")
																											If RetVal Then
																												If UCASE(input.item("FZG_ART")) <> "PKW" Then
																													Sendkey "{TAB}"
																													Sendkey "{TAB}"
																													Wert_amount = input.item("Wert")
																													Sendkey Wert_amount
																												End If
																												Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaObject("Grid")
																												JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaObject("Grid").Click "27","81"	'To click on JavaObject
																												If RetVal Then
																													Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaStaticText("RC_SFR_SideTab")
																													RetVal = fnStaticTextClick(objOP,"RC_Object_Detail", "12","13")
																													If RetVal Then
																														Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaEdit("RC_SFR_Rabattgrundjahr")
																														RetVal = fnEnterData(objOP, input.item("Rabattgrundjahr"))
																														If RetVal Then
																															Sendkey "{TAB}"
																															Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaEdit("RC_SFR_Riskoclasse")
																															RetVal = fnEnterData(objOP, input.item("Riskoclasse1"))
																															If RetVal Then
																															Sendkey "{TAB}"
																															Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaEdit("RC_KH01")
																															RetVal = fnEnterData(objOP, input.item("EinstufungsGrund"))
																																If RetVal Then
																																Sendkey "{TAB}"
																																Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaEdit("RC_SFR_Rabatt2")
																																RetVal = fnEnterData(objOP, input.item("Rabattgrundjahr2"))
																																	If RetVal Then
																																	Sendkey "{TAB}"
																																	Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaEdit("RC_SFR_Riskoclasse2")
																																	RetVal = fnEnterData(objOP, input.item("Riskoclasse2"))
																																		If RetVal Then
																																			Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaStaticText("RC_Inkasso")
																																			RetVal = fnStaticTextClick(objOP,"RC_Inkasso", "10","12")
																																			If RetVal Then
																																				Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaWindow("Ereignisanzeige")
																																				Call fnHandleDialogBoxButton(objOP,"Schließen")
																																				If RetVal Then
																																					Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaStaticText("RC_Inkasso")
																																					RetVal = fnStaticTextClick(objOP,"RC_Inkasso", "10","12")
																																					If RetVal Then
																																						Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaEdit("RC_Inkassoart")
																																						RetVal = fnEnterData(objOP, input.item("Inkassoart"))
																																						wait 2
																																						If Lcase(input.item("Inkassoart")) = "lastschriftverfahren" Then
																																							Set objOP = JavaWindow("Akte Vertrag KFZ [FO1457958191").JavaStaticText("Bank/KK(st)")
																																							RetVal = fnStaticTextClick(objOP,"Bank/KK(st)", "36","12")
																																							If RetVal Then
																																								Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaTable("Zahlungskarten")
																																								RetVal = fnTableSelectCell(objOP,"0","BIC")
																																								If RetVal Then
																																									Sendkey "BFSWDE33XXX"
																																									Sendkey "{TAB}"
																																									Sendkey "DE23370205000008090100"
																																									wait 1
																																								End If
																																							End If
																																						End If
																																						If RetVal Then
																																							Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaStaticText("RC_Zusatz_Tab")
																																							RetVal = fnStaticTextClick(objOP,"RC_Inkasso", "35","10")
																																							If RetVal Then
																																								RetVal = fnRC_Zusatz_Questions()
																																								If RetVal Then
																																									Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaStaticText("RC_Zusatz_InnerTab")
																																									RetVal = fnStaticTextClick(objOP,"RC_Zusatz_InnerTab", "32","6")
																																									If RetVal Then
																																										Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaRadioButton("RC_Zusatz_Innertab_OptBtn")
																																										RetVal = fnSelectRadioButton(objOP, "RC_Zusatz_Innertab_OptBtn")
																																										If RetVal Then
																																											Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaObject("RC_Caluculator")
																																											JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaObject("RC_Caluculator").Click "15","12"
																																											wait 4
																																											If RetVal Then
																																												Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaWindow("Ereignisanzeige")
																																												Call fnHandleDialogBoxButton(objOP,"Schließen")
																																												If RetVal Then
																																													JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaObject("RC_Forward_Button").Click "17","10"
																																													If RetVal Then
																																														JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaObject("RC_Contract_Amendment_Flow.objjobj_Speichern_Save").Click "13","17"	
																																														If RetVal Then
																																															Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaWindow("Akte Vertrag").JavaButton("RC_G08_SecondPopUP")
																																															RetVal = fnButtonClick(objOP, "RC_G08_SecondPopUP")
																																															wait 8
																																															If RetVal Then
																																																Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaWindow("Ereignisanzeige")
																																																RetVal = fnHandleDialogBoxButton(objOP,"Schließen")
																																																If RetVal Then
																																																Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaWindow("Ereignisanzeige").JavaEdit("RC_FinalContractCreation_Popup")
																																																	val = objOP.GetROProperty("Value")
																																																	If UCASE(val) = UCASE("Zu dem gewählten Inkassoweg wurde ein neues SEPA-Mandat erzeugt.") Then
																																																		fnRC_Contract_creation = "True"
																																																		'Take screenshot
																																																		If RetVal Then
																																																			Set objOP = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaWindow("Ereignisanzeige").JavaButton("RC_ContractCreation_Info_Popup")
																																																			RetVal = fnButtonClick(objOP, "RC_ContractCreation_Info_Popup")
																																																			If RetVal Then
																																																				Set objOP = JavaWindow("Akte Vertrag KFZ [FO1457958191").JavaStaticText("RC_Contract_Amendment_Flow.sttjstt_Produkte_Tab")
																																																				RetVal = fnStaticTextClick(objOP,"RC_Zusatz_InnerTab", "10","8")
																																																				If RetVal Then
																																																					strContractStatus = JavaWindow("RC_Search_Contract.wndJwnd_Akte_Vertrag").JavaTable("RC_AntragFertig_Check").GetCellData(2,1)
																																																					If instr(strContractStatus,"Antrag, fertig") <> 0 Then
																																																						 fnRC_Contract_creation = "True"
																																																					Else
																																																						fnRC_Contract_creation = "False"
																																																					End If
																																																					'StrContractNo = mid(strContractStatus,1,12)
																																																				End If
																																																			End If
																																																		End If
																																																	End If
																																																End If
																																															End If
																																														End If
																																													End If
																																												End If
																																											End If
																																										End If
																																									End If
																																								End If
																																							End If
																																						End If
																																					End If
																																				End If
																																			End If
																																		End If
																																	End If
																																End If
																															End If
																														End If
																													End If
																												End If
																											End If
																										End If
																									End If
																								End If
																							End If
																						End If
																					End If
																				End If
																			End If
																		End If
																	End If
																End If
															End If
														End If
													End If
												End If
											End If
										End If
									End If
								End If
							End If
						End If
					End If
				End If
			End If
		End If
				
	Else
		errmsg = "Person not found for creating contract|Fail"	
	End If
	
	If fnRC_Contract_creation = "True" Then
		fnTraceLogs "Contract Create = " & input("Type@jedt_PolicyNummer") & " | " & errMsg,1,1		
		fnUpdateExecutionDetailsXL "Contract Search", input("Type@jedt_PolicyNummer"), "Pass", "Y", "Y"
	Else
		fnTraceLogs "Contract Create = " & input("Type@jedt_PolicyNummer") & " | " & errMsg,1,1		
		fnUpdateExecutionDetailsXL "Contract Search", input("Type@jedt_PolicyNummer"), "Fail", "Y", "Y"	
	End If
	
End Function

