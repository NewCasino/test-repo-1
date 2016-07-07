namespace Luxbook.MVC.Services
{
    using System.Web;

    public interface ISecurityService
    {
        string GetCurrentUser();
    }

    public class SecurityService : ISecurityService
    {
        private readonly HttpContextBase _httpContextBase;

        public SecurityService(HttpContextBase httpContextBase)
        {
            _httpContextBase = httpContextBase;
        }

        public string GetCurrentUser()
        {
            return _httpContextBase.Session["LID"] as string;
        }
    }
}