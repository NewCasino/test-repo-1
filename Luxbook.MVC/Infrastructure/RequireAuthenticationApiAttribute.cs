namespace Luxbook.MVC.Infrastructure
{
    using System.Web;
    using System.Web.Http;
    using System.Web.Http.Controllers;

    /// <summary>
    ///     This is used for server to server API calls where an api key is used instead
    /// </summary>
    public class RequireAuthenticationApiAttribute : AuthorizeAttribute
    {
        protected override bool IsAuthorized(HttpActionContext actionContext)
        {
            // not sure if we're going to use this much so just hard code for now
            // in the future we'll need a securityservice and servicelocator
            var key = HttpContext.Current.Request.QueryString["key"];
            if (!string.IsNullOrEmpty(key) && key.ToUpper() == "1954ED80-7181-4EFA-818D-A8BE2F03C692")
            {
                return true;
            }

            return false;
        }
    }
}