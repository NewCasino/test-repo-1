<%@ Page Language="VB" AutoEventWireup="false" CodeFile="AccessLog.aspx.vb" Inherits="AccessLog" %>

<!DOCTYPE html >

<html>
	<meta http-equiv="content-type" content="text/html; charset=UTF-8">
	<link rel="stylesheet" href="/global.css">
	<script src="/global.js"></script>
	<script>top.setTitle("Access Log")</script>

<body>
	<div id=CNT style="top:25px; left:25px; width:600px">
        <form id="form1" runat="server">
            <div class=LST><!--  BorderWidth="1" GridLines="Both"  -->
                <asp:Table id="USERTAB"  cellpadding="3" runat="server" >
                    <asp:TableHeaderRow id="Table1HeaderRow" runat="server">
                        <asp:TableHeaderCell  Scope="Column"  Text="Name" />
                        <asp:TableHeaderCell  Scope="Column"  Text="Dept" />
                        <asp:TableHeaderCell  Scope="Column"  Text="Login" />
                        <asp:TableHeaderCell  Scope="Column"  Text="Logout" />
                    </asp:TableHeaderRow> 
                </asp:Table> 
            </div>
        </form>
    </div>
</body>
</html>
