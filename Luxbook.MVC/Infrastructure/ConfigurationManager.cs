namespace Luxbook.MVC.Infrastructure
{
    public class ConfigurationManager : IConfigurationManager
    {
        #region Implementation of IConfigurationManager

        public string GetConnectionString()
        {
            return System.Configuration.ConfigurationManager.ConnectionStrings["Default"].ConnectionString;
        }

        public string GetSetting(string key)
        {
            return System.Configuration.ConfigurationManager.AppSettings[key];
        }

        #endregion
    }
}