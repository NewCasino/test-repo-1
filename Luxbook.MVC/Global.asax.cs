using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using System.Web.Security;
using System.Web.SessionState;
using System.Web.Http;

namespace Luxbook.MVC
{
    using App_Start;

    public class Global : HttpApplication
    {
        void Application_Start(object sender, EventArgs e)
        {
            // Code that runs on application startup
            AreaRegistration.RegisterAllAreas();
            GlobalConfiguration.Configure(WebApiConfig.Register);
            RouteConfig.RegisterRoutes(RouteTable.Routes);     
            UnityWebActivator.Start();
            ValueProviderFactories.Factories.Add(new JsonValueProviderFactory());
        }

        protected void Application_PostAuthorizeRequest()
        {
                HttpContext.Current.SetSessionStateBehavior(SessionStateBehavior.Required);
        }
      
    }
}