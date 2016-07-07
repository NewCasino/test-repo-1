<%@ Page Language="VB" AutoEventWireup="false" CodeFile="BoxChl.aspx.vb" Inherits="BoxChl" %>
<%@ Register TagPrefix="WT" TagName="Main"  Src="~/ascx/main.ascx"  %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
	<meta http-equiv="content-type" content="text/html; charset=UTF-8">
	<link rel="stylesheet" href="../global.css">
	<script src="../global.js"></script>
	<script>
	   // top.setTitle("Box Challenge");

    </script>

<body>
    <div id=CNT style="top:30px; left:30px; width:1000px">
    <form id="BoxChl" runat="server">
        <div class=LST>

            <asp:Table id="TableBox" cellspacing=0  cellpadding="4" runat="server" >
                <asp:TableHeaderRow id="TableHeaderRow0" runat="server">
                    <asp:TableHeaderCell  Text="<label id='BxTime'>"  ColumnSpan="1"  class=TT>
                    </asp:TableHeaderCell>
                    <asp:TableHeaderCell  Text="<img src= '../img/G.png'> TAB Box Challenge  "  ColumnSpan="9"  class=TT>
                        <asp:Image ID="AUflag" class="FLG" runat="server" AlternateText="AU" ImageUrl="../img/AU.jpg"/>&nbsp
                        <asp:Image ID="NZflag" class="FLG" runat="server" AlternateText="NZ" ImageUrl="../img/NZ.jpg"/>
                    </asp:TableHeaderCell>
                </asp:TableHeaderRow>

                <asp:TableHeaderRow id="TableHeaderRow1" runat="server">
                    <asp:TableHeaderCell  Scope="Column"  ColumnSpan="2" Text="Venue"/>
                    <asp:TableHeaderCell  Scope="Column"  Text="1" />
                    <asp:TableHeaderCell  Scope="Column"  Text="2" />
                    <asp:TableHeaderCell  Scope="Column"  Text="3" />
                    <asp:TableHeaderCell  Scope="Column"  Text="4" />
                    <asp:TableHeaderCell  Scope="Column"  Text="5" />
                    <asp:TableHeaderCell  Scope="Column"  Text="6" />
                    <asp:TableHeaderCell  Scope="Column"  Text="7" />
                    <asp:TableHeaderCell  Scope="Column"  Text="8" />
                </asp:TableHeaderRow> 
            </asp:Table>
            <br><p>
            
            <asp:Table id="TableLXB" cellspacing=0  cellpadding="4" runat="server" >
                <asp:TableHeaderRow id="TableHeaderRow2" runat="server">
                    <asp:TableHeaderCell  Text=""  ColumnSpan="1"  class=TT>
                    </asp:TableHeaderCell>
                    <asp:TableHeaderCell  Text="<img src= '../img/G.png'> Luxbet Box Challenge  "  ColumnSpan="9"  class=TT>
                        <asp:Image ID="Image1" class="FLG" runat="server" AlternateText="AU" ImageUrl="../img/AU.jpg"/>&nbsp
                        <asp:Image ID="Image2" class="FLG" runat="server" AlternateText="NZ" ImageUrl="../img/NZ.jpg"/>
                    </asp:TableHeaderCell>
                </asp:TableHeaderRow>

                <asp:TableHeaderRow id="TableHeaderRow3" runat="server">
                    <asp:TableHeaderCell  Scope="Column"  ColumnSpan="2" Text="Venue"/>
                    <asp:TableHeaderCell  Scope="Column"  Text="1" />
                    <asp:TableHeaderCell  Scope="Column"  Text="2" />
                    <asp:TableHeaderCell  Scope="Column"  Text="3" />
                    <asp:TableHeaderCell  Scope="Column"  Text="4" />
                    <asp:TableHeaderCell  Scope="Column"  Text="5" />
                    <asp:TableHeaderCell  Scope="Column"  Text="6" />
                    <asp:TableHeaderCell  Scope="Column"  Text="7" />
                    <asp:TableHeaderCell  Scope="Column"  Text="8" />
                </asp:TableHeaderRow> 
            </asp:Table>  
        </div>

	<script>
	        var dt = new Date();
	        //document.getElementById("BxTime").innerHTML = dt.toLocaleTimeString().substring(0, 5);
	        $("BxTime").innerHTML = dt.toLocaleTimeString().substring(0, 5);
	        //alert(dt.toLocaleTimeString().substring(0,5));
    </script>

    </form>
    </div>
</body>
</html>

