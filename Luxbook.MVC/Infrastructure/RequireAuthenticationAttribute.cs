namespace Luxbook.MVC.Infrastructure
{
    using System.Web.Mvc;

    public class RequireAuthenticationAttribute : AuthorizeAttribute 
    {
        #region Overrides of AuthorizeAttribute

        /// <summary>
        ///     Called when a process requests authorization.
        /// </summary>
        /// <param name="filterContext">
        ///     The filter context, which encapsulates information for using
        ///     <see cref="T:System.Web.Mvc.AuthorizeAttribute" />.
        /// </param>
        /// <exception cref="T:System.ArgumentNullException">The <paramref name="filterContext" /> parameter is null.</exception>
        public override void OnAuthorization(AuthorizationContext filterContext)
        {
            if (filterContext.HttpContext.Session != null)
            {
                var lid = filterContext.HttpContext.Session["LID"] as string;
                if (!string.IsNullOrEmpty(lid))
                {
                    return;
                }
            }

            filterContext.Result = new RedirectResult("../");
        }

        #endregion
    }
}