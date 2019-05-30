create trigger t_SendWeeklySalesEmail ON WeeklyTimerTable
AFTER INSERT
AS
BEGIN


	DECLARE @Type VARCHAR(255),
	 @CustomerName VARCHAR(255),
	@SONumber VARCHAR(255),
	@SerialNumber VARCHAR(255),
	@Trial_Loaner_BeginDate VARCHAR(255),
	@DaysOnTrial_Loan VARCHAR(255),
	@Description VARCHAR(255),
	@SalesRepEmail VARCHAR(255),


	@Body NVARCHAR(MAX),
	@TableHead VARCHAR(1000),
	@TableTail VARCHAR(1000)


	
	DECLARE MY_CURSOR CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
	FOR
	select * from v_TrialsAndLoaners


	OPEN MY_CURSOR


	FETCH NEXT
	FROM MY_CURSOR
	INTO @Type
		,@CustomerName
		,@SONumber
		,@SerialNumber
		,@Trial_Loaner_BeginDate
		,@DaysOnTrial_Loan
		,@Description
		,@SalesRepEmail
		


	WHILE @@FETCH_STATUS = 0
	BEGIN


	--create body
	Declare @myBody varchar(max)
	Set @myBody = 'Hello, <br>
				   You currently have a '+@Type+' assigned to a customer. Below is the info: <br>
				   <br>
				   Type: ' + @Type + '<br>
				   Customer Name: ' + @CustomerName +'<br>
				   Description: '+@Description+'<br>
				   Serial Number: ' + @SerialNumber + '<br>
				   '+@Type+' begin date: ' + @Trial_Loaner_BeginDate + '<br>
				   <br>
				   Thank you, <br>
				   -Business Intelligence Team'
	--create body


	Declare @mySubject varchar(255)
	Set @mySubject = 'Weekly '+ @Type + ' Notice'


		EXEC msdb.dbo.sp_send_dbmail 
             @recipients = @SalesRepEmail	
			,@subject = @mySubject
			,@body = @myBody
			,@body_format = 'HTML'


		


		FETCH NEXT
		FROM MY_CURSOR
		INTO @Type
		,@CustomerName
		,@SONumber
		,@SerialNumber
		,@Trial_Loaner_BeginDate
		,@DaysOnTrial_Loan
		,@Description
		,@SalesRepEmail
	END


	CLOSE MY_CURSOR


	DEALLOCATE MY_CURSOR
	


END