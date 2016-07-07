<!-- #include file="/inc/page.inc" --><%

execSQL("UPDATE TRADER_LOG SET DTM_OUT=GETDATE() WHERE ROW_ID=0" & Session("LOG"))
Session.Contents.RemoveAll

%><script>top.location.reload()</script>