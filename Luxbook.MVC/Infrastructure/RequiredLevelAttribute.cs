namespace Luxbook.MVC.Infrastructure
{
    using System;
    using System.Web.Mvc;

    public class RequiredLevelAttribute : AuthorizeAttribute
    {
        public RequiredLevelAttribute(int maximumLevelAllowed)
        {
            MaximumLevelAllowed = maximumLevelAllowed;
        }

        public int MaximumLevelAllowed { get; set; }

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
                int lid;
                if (Int32.TryParse(filterContext.HttpContext.Session["LVL"].ToString(), out lid))
                {
                    if (lid <= MaximumLevelAllowed)
                    {
                        return;
                    }
                }
            }

            filterContext.Result = new RedirectResult("../");
        }

        #endregion
    }
}