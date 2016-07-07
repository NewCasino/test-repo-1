namespace Luxbook.MVC
{
    using System.Web.Mvc;
    using System.Web.Routing;

    public class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

            routes.MapRoute("RulesEdit", "rules/edit/{ruleId}", new {controller = "Rules", action = "Edit"}
                );

            routes.MapRoute("TradeEdit", "trademanagement/editaccount/{eventTradingAccountId}",
                new {controller = "trademanagement", action = "editaccount"}
                );

            routes.MapRoute("Default", "{controller}/{action}/{id}",
                new {controller = "Default", action = "Index", id = UrlParameter.Optional}
                );
        }
    }
}