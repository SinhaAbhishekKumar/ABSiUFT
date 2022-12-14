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
						svalue = coll(1).GetRoProperty("value")
						If InStr(1, svalue, input.item("Person_FirstName")) > 0 Then
							Set objOP = JavaWindow("Person suchen <auf DTGEP45>").JavaButton("RC_Person_OK")
							RetVal = fnButtonClick(objOP, "OK")
							fnRC_Search_Existing_Person = "True"
						Else
							errMsg = "Person Not Found | Exit"
							fnRC_Search_Existing_Person = "False"
						End If
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
																										wait 2
																										If RetVal Then
																											Set objOP = JavaWindow("Akte Juristische Person").JavaWindow("Achtung!")
																											RetVal = fnButtonClick(objOP,"Ja")
																											wait 1
																											If RetVal Then
																												fnRC_Create_Person = "True"
																											Else
																												errMsg = "Legal Person not created|Exit"
																												fnRC_Create_Person = "False"
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
																 																					If RetVal Then
																 																						fnRC_Create_Person = "True"
																 																					Else
																 																						errMsg = "Natural Person not created|Exit"
																 																						fnRC_Create_Person = "False"
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
			fnUpdateExecutionDetailsXL "Person Create", input("Person_FirstName") &" "& input("Person_SecondName"), "Pass", "Y", "Y"
		Else
			fnTraceLogs "Person Create = " & input("Person_FirstName") &" "& input("Person_SecondName") & " | " & errMsg,1,1		
			fnUpdateExecutionDetailsXL "Person Create", input("Person_FirstName") &" "& input("Person_SecondName"), "Fail", "Y", "Y"	
		End If
		
End Function
