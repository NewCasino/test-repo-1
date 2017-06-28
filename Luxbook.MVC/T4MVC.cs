﻿// <auto-generated />
// This file was generated by a T4 template.
// Don't change it directly as your change would get overwritten.  Instead, make changes
// to the .tt file (i.e. the T4 template) and save it to regenerate this file.

// Make sure the compiler doesn't complain about missing Xml comments and CLS compliance
// 0108: suppress "Foo hides inherited member Foo. Use the new keyword if hiding was intended." when a controller and its abstract parent are both processed
// 0114: suppress "Foo.BarController.Baz()' hides inherited member 'Qux.BarController.Baz()'. To make the current member override that implementation, add the override keyword. Otherwise add the new keyword." when an action (with an argument) overrides an action in a parent controller
#pragma warning disable 1591, 3008, 3009, 0108, 0114
#region T4MVC

using System;
using System.Diagnostics;
using System.CodeDom.Compiler;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Threading.Tasks;
using System.Web;
using System.Web.Hosting;
using System.Web.Mvc;
using System.Web.Mvc.Ajax;
using System.Web.Mvc.Html;
using System.Web.Routing;
using T4MVC;

[GeneratedCode("T4MVC", "2.0"), DebuggerNonUserCode]
public static partial class Mvc
{
    public static Luxbook.MVC.Controllers.AlertsController Alerts = new Luxbook.MVC.Controllers.T4MVC_AlertsController();
    public static Luxbook.MVC.Controllers.DefaultController Default = new Luxbook.MVC.Controllers.T4MVC_DefaultController();
    public static Luxbook.MVC.Controllers.LiabilityController Liability = new Luxbook.MVC.Controllers.T4MVC_LiabilityController();
    public static Luxbook.MVC.Controllers.MaxExposureController MaxExposure = new Luxbook.MVC.Controllers.T4MVC_MaxExposureController();
    public static Luxbook.MVC.Controllers.MeetingMatchController MeetingMatch = new Luxbook.MVC.Controllers.T4MVC_MeetingMatchController();
    public static Luxbook.MVC.Controllers.ReportsController Reports = new Luxbook.MVC.Controllers.T4MVC_ReportsController();
    public static Luxbook.MVC.Controllers.RulesController Rules = new Luxbook.MVC.Controllers.T4MVC_RulesController();
    public static Luxbook.MVC.Controllers.StakingController Staking = new Luxbook.MVC.Controllers.T4MVC_StakingController();
    public static Luxbook.MVC.Controllers.TradeManagementController TradeManagement = new Luxbook.MVC.Controllers.T4MVC_TradeManagementController();
    public static T4MVC.SharedController Shared = new T4MVC.SharedController();
}

namespace T4MVC
{
}

namespace T4MVC
{
    [GeneratedCode("T4MVC", "2.0"), DebuggerNonUserCode]
    public class Dummy
    {
        private Dummy() { }
        public static Dummy Instance = new Dummy();
    }
}

[GeneratedCode("T4MVC", "2.0"), DebuggerNonUserCode]
internal partial class T4MVC_System_Web_Mvc_ActionResult : System.Web.Mvc.ActionResult, IT4MVCActionResult
{
    public T4MVC_System_Web_Mvc_ActionResult(string area, string controller, string action, string protocol = null): base()
    {
        this.InitMVCT4Result(area, controller, action, protocol);
    }
     
    public override void ExecuteResult(System.Web.Mvc.ControllerContext context) { }
    
    public string Controller { get; set; }
    public string Action { get; set; }
    public string Protocol { get; set; }
    public RouteValueDictionary RouteValueDictionary { get; set; }
}
[GeneratedCode("T4MVC", "2.0"), DebuggerNonUserCode]
internal partial class T4MVC_System_Web_Mvc_JsonResult : System.Web.Mvc.JsonResult, IT4MVCActionResult
{
    public T4MVC_System_Web_Mvc_JsonResult(string area, string controller, string action, string protocol = null): base()
    {
        this.InitMVCT4Result(area, controller, action, protocol);
    }
    
    public string Controller { get; set; }
    public string Action { get; set; }
    public string Protocol { get; set; }
    public RouteValueDictionary RouteValueDictionary { get; set; }
}



namespace Links
{
    [GeneratedCode("T4MVC", "2.0"), DebuggerNonUserCode]
    public static class Scripts {
        private const string URLPATH = "~/Scripts";
        public static string Url() { return T4MVCHelpers.ProcessVirtualPath(URLPATH); }
        public static string Url(string fileName) { return T4MVCHelpers.ProcessVirtualPath(URLPATH + "/" + fileName); }
        public static readonly string bootstrap_js = T4MVCHelpers.IsProduction() && T4Extensions.FileExists(URLPATH + "/bootstrap.min.js") ? Url("bootstrap.min.js") : Url("bootstrap.js");
        public static readonly string bootstrap_min_js = Url("bootstrap.min.js");
        public static readonly string common_js = T4MVCHelpers.IsProduction() && T4Extensions.FileExists(URLPATH + "/common.min.js") ? Url("common.min.js") : Url("common.js");
        public static readonly string config_js = T4MVCHelpers.IsProduction() && T4Extensions.FileExists(URLPATH + "/config.min.js") ? Url("config.min.js") : Url("config.js");
        public static readonly string jquery_2_1_4_intellisense_js = T4MVCHelpers.IsProduction() && T4Extensions.FileExists(URLPATH + "/jquery-2.1.4.intellisense.min.js") ? Url("jquery-2.1.4.intellisense.min.js") : Url("jquery-2.1.4.intellisense.js");
        public static readonly string jquery_2_1_4_js = T4MVCHelpers.IsProduction() && T4Extensions.FileExists(URLPATH + "/jquery-2.1.4.min.js") ? Url("jquery-2.1.4.min.js") : Url("jquery-2.1.4.js");
        public static readonly string jquery_2_1_4_min_js = Url("jquery-2.1.4.min.js");
        public static readonly string jquery_2_1_4_min_map = Url("jquery-2.1.4.min.map");
        public static readonly string knockout_3_3_0_debug_js = T4MVCHelpers.IsProduction() && T4Extensions.FileExists(URLPATH + "/knockout-3.3.0.debug.min.js") ? Url("knockout-3.3.0.debug.min.js") : Url("knockout-3.3.0.debug.js");
        public static readonly string knockout_3_3_0_js = T4MVCHelpers.IsProduction() && T4Extensions.FileExists(URLPATH + "/knockout-3.3.0.min.js") ? Url("knockout-3.3.0.min.js") : Url("knockout-3.3.0.js");
        public static readonly string knockout_validation_js = T4MVCHelpers.IsProduction() && T4Extensions.FileExists(URLPATH + "/knockout.validation.min.js") ? Url("knockout.validation.min.js") : Url("knockout.validation.js");
        public static readonly string knockout_validation_min_js = Url("knockout.validation.min.js");
        public static readonly string knockout_validation_min_js_map = Url("knockout.validation.min.js.map");
        public static readonly string knockout_viewmodel_2_0_3_js = T4MVCHelpers.IsProduction() && T4Extensions.FileExists(URLPATH + "/knockout.viewmodel.2.0.3.min.js") ? Url("knockout.viewmodel.2.0.3.min.js") : Url("knockout.viewmodel.2.0.3.js");
        public static readonly string knockout_viewmodel_2_0_3_min_js = Url("knockout.viewmodel.2.0.3.min.js");
        public static readonly string modernizr_2_8_3_js = T4MVCHelpers.IsProduction() && T4Extensions.FileExists(URLPATH + "/modernizr-2.8.3.min.js") ? Url("modernizr-2.8.3.min.js") : Url("modernizr-2.8.3.js");
        public static readonly string moment_with_locales_js = T4MVCHelpers.IsProduction() && T4Extensions.FileExists(URLPATH + "/moment-with-locales.min.js") ? Url("moment-with-locales.min.js") : Url("moment-with-locales.js");
        public static readonly string moment_with_locales_min_js = Url("moment-with-locales.min.js");
        public static readonly string moment_js = T4MVCHelpers.IsProduction() && T4Extensions.FileExists(URLPATH + "/moment.min.js") ? Url("moment.min.js") : Url("moment.js");
        public static readonly string moment_min_js = Url("moment.min.js");
    }

    [GeneratedCode("T4MVC", "2.0"), DebuggerNonUserCode]
    public static class Content {
        private const string URLPATH = "~/Content";
        public static string Url() { return T4MVCHelpers.ProcessVirtualPath(URLPATH); }
        public static string Url(string fileName) { return T4MVCHelpers.ProcessVirtualPath(URLPATH + "/" + fileName); }
        public static readonly string bootstrap_theme_css = T4MVCHelpers.IsProduction() && T4Extensions.FileExists(URLPATH + "/bootstrap-theme.min.css") ? Url("bootstrap-theme.min.css") : Url("bootstrap-theme.css");
             
        public static readonly string bootstrap_theme_css_map = Url("bootstrap-theme.css.map");
        public static readonly string bootstrap_theme_min_css = Url("bootstrap-theme.min.css");
        public static readonly string bootstrap_css = T4MVCHelpers.IsProduction() && T4Extensions.FileExists(URLPATH + "/bootstrap.min.css") ? Url("bootstrap.min.css") : Url("bootstrap.css");
             
        public static readonly string bootstrap_css_map = Url("bootstrap.css.map");
        public static readonly string bootstrap_min_css = Url("bootstrap.min.css");
        public static readonly string global_css = T4MVCHelpers.IsProduction() && T4Extensions.FileExists(URLPATH + "/global.min.css") ? Url("global.min.css") : Url("global.css");
             
        public static readonly string Site_less = Url("Site.less");
        public static readonly string Site_css = T4MVCHelpers.IsProduction() && T4Extensions.FileExists(URLPATH + "/Site.min.css") ? Url("Site.min.css") : Url("Site.css");
             
        public static readonly string Site_min_css = Url("Site.min.css");
    }

    
    [GeneratedCode("T4MVC", "2.0"), DebuggerNonUserCode]
    public static partial class Bundles
    {
        public static partial class Scripts 
        {
            public static class Assets
            {
                public const string bootstrap_js = "~/Scripts/bootstrap.js"; 
                public const string bootstrap_min_js = "~/Scripts/bootstrap.min.js"; 
                public const string common_js = "~/Scripts/common.js"; 
                public const string config_js = "~/Scripts/config.js"; 
                public const string jquery_2_1_4_intellisense_js = "~/Scripts/jquery-2.1.4.intellisense.js"; 
                public const string jquery_2_1_4_js = "~/Scripts/jquery-2.1.4.js"; 
                public const string jquery_2_1_4_min_js = "~/Scripts/jquery-2.1.4.min.js"; 
                public const string knockout_3_3_0_debug_js = "~/Scripts/knockout-3.3.0.debug.js"; 
                public const string knockout_3_3_0_js = "~/Scripts/knockout-3.3.0.js"; 
                public const string knockout_validation_js = "~/Scripts/knockout.validation.js"; 
                public const string knockout_validation_min_js = "~/Scripts/knockout.validation.min.js"; 
                public const string knockout_viewmodel_2_0_3_js = "~/Scripts/knockout.viewmodel.2.0.3.js"; 
                public const string knockout_viewmodel_2_0_3_min_js = "~/Scripts/knockout.viewmodel.2.0.3.min.js"; 
                public const string modernizr_2_8_3_js = "~/Scripts/modernizr-2.8.3.js"; 
                public const string moment_with_locales_js = "~/Scripts/moment-with-locales.js"; 
                public const string moment_with_locales_min_js = "~/Scripts/moment-with-locales.min.js"; 
                public const string moment_js = "~/Scripts/moment.js"; 
                public const string moment_min_js = "~/Scripts/moment.min.js"; 
            }
        }
        public static partial class Content 
        {
            public static class Assets
            {
                public const string bootstrap_theme_css = "~/Content/bootstrap-theme.css";
                public const string bootstrap_theme_min_css = "~/Content/bootstrap-theme.min.css";
                public const string bootstrap_css = "~/Content/bootstrap.css";
                public const string bootstrap_min_css = "~/Content/bootstrap.min.css";
                public const string global_css = "~/Content/global.css";
            }
        }
    }
}

[GeneratedCode("T4MVC", "2.0"), DebuggerNonUserCode]
internal static class T4MVCHelpers {
    // You can change the ProcessVirtualPath method to modify the path that gets returned to the client.
    // e.g. you can prepend a domain, or append a query string:
    //      return "http://localhost" + path + "?foo=bar";
    private static string ProcessVirtualPathDefault(string virtualPath) {
        // The path that comes in starts with ~/ and must first be made absolute
        string path = VirtualPathUtility.ToAbsolute(virtualPath);
        
        // Add your own modifications here before returning the path
        return path;
    }

    // Calling ProcessVirtualPath through delegate to allow it to be replaced for unit testing
    public static Func<string, string> ProcessVirtualPath = ProcessVirtualPathDefault;

    // Calling T4Extension.TimestampString through delegate to allow it to be replaced for unit testing and other purposes
    public static Func<string, string> TimestampString = System.Web.Mvc.T4Extensions.TimestampString;

    // Logic to determine if the app is running in production or dev environment
    public static bool IsProduction() { 
        return (HttpContext.Current != null && !HttpContext.Current.IsDebuggingEnabled); 
    }
}





#endregion T4MVC
#pragma warning restore 1591, 3008, 3009, 0108, 0114


