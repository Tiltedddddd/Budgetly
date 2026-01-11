<%@ Page Title="Your Wallets" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="walletsPage.aspx.cs" Inherits="Budgetly.Pages.walletsPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link runat="server" href="~/Content/css/walletsPage.css" rel="stylesheet"/>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <!-- =============== Display Wallet ================= -->
    <asp:GridView 
        ID="gV_WalletScreen" 
        runat="server" 
        AutoGenerateColumns="False" 
        OnSelectedIndexChanged="GridView1_SelectedIndexChanged"
        OnRowDataBound="gV_WallerScreen_RowDataBound">
        <Columns>
            <asp:BoundField DataField="AccountName" />
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:Label ID="lbl_Gmailsync" runat="server" Text="Email Sync"></asp:Label>
                    <br />
                    <asp:LinkButton 
                        ID="btn_Parse" 
                        runat="server" 
                        CommandArgument="IsGmailSyncEnabled" 
                        CommandName="SyncEmail"
                        >Set up parsing</asp:LinkButton>
                    <br />
                    <span id="DefaultText" runat="server">Default</span>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="Balance" />
            <asp:HyperLinkField NavigateUrl="~/Pages/transactionsPage.aspx" Text="View Transactions" />
            <asp:CommandField ShowEditButton="True" DeleteText="Remove" SelectText="Set to Default" ShowDeleteButton="True" ShowSelectButton="True" />
            <asp:ImageField DataImageUrlField="ImagePath">
            </asp:ImageField>
        </Columns>
    </asp:GridView>

    
    <br />
    <!-- ======= Add Card ======== -->
    <asp:Button ID="btn_addCard" runat="server" Text="+ Add Card" OnClick="btn_addCard_Click" />
    
    <br />
    <asp:Panel ID="pn_AddWallet" runat="server" Visible="False">
        <asp:Label ID="lbl_AccountName" runat="server" Text="Name: "></asp:Label>

        <br />
        <asp:TextBox ID="tb_Name" runat="server"></asp:TextBox>

        <br />
        <asp:RequiredFieldValidator 
            ID="rfv_AccountName" 
            runat="server" 
            ControlToValidate="tb_Name" 
            ErrorMessage="Name is required" 
            ForeColor="Red" 
            ValidationGroup="CreateWallet"></asp:RequiredFieldValidator>

        <br />

        <asp:Label ID="tb_AccountType" runat="server" Text="Type: "></asp:Label>
        <br />
        <asp:DropDownList ID="ddl_Type" runat="server">
            <asp:ListItem>Debit</asp:ListItem>
            <asp:ListItem>Credit</asp:ListItem>
            <asp:ListItem>Cash</asp:ListItem>
            <asp:ListItem>Savings</asp:ListItem>
            <asp:ListItem>Digital</asp:ListItem>
        </asp:DropDownList>

        <br />
        <asp:RequiredFieldValidator 
            ID="rfv_AccountType" 
            runat="server" 
            ControlToValidate="ddl_Type" 
            ErrorMessage="Type is required" 
            ForeColor="Red" 
            ValidationGroup="CreateWallet">
        </asp:RequiredFieldValidator>

        <br />

        <asp:Label ID="lbl_Balance" runat="server" Text="Balance: "></asp:Label>
        <br />
        <asp:TextBox ID="tb_Balance" runat="server"></asp:TextBox>
        <br />
        <asp:RequiredFieldValidator 
            ID="rfv_Balance" 
            runat="server" 
            ControlToValidate="tb_Balance" 
            ErrorMessage="Balance is required" 
            ForeColor="Red" 
            ValidationGroup="CreateWallet">
        </asp:RequiredFieldValidator>
        <asp:CompareValidator 
            ID="cV_Balance" 
            runat="server" 
            ControlToValidate="tb_Balance" 
            ErrorMessage="Only numbers are allowed" 
            ForeColor="Red" 
            Type="Double" 
            ValidationGroup="CreateWallet"></asp:CompareValidator>
        <br />
        <asp:Button ID="btn_Createwallet" runat="server" Text="Add" OnClick="btn_Createwallet_Click" ValidationGroup="CreateWallet" />
        <asp:Button ID="btn_Cancel" runat="server" Text="Cancel" OnClick="btn_Cancel_Click" />
    </asp:Panel>
    
</asp:Content>
