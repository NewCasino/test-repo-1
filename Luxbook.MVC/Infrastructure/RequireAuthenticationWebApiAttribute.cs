namespace Luxbook.MVC.Infrastructure
{
    using System.Web;
    using System.Web.Http;
    using System.Web.Http.Controllers;

    /// <summary>
    /// This is used for user to server API calls (e.g. ajax endpoints)
    /// </summary>
    public class RequireAuthenticationWebApiAttribute : AuthorizeAttribute
    {
        protected override bool IsAuthorized(HttpActionContext actionContext)
        {
            if (HttpContext.Current.Session != null)
            {
                var lid = HttpContext.Current.Session["LID"] as string;
                if (!string.IsNullOrEmpty(lid))
                {
                    return true;
                }
            }
            return false;
        }
    }
}