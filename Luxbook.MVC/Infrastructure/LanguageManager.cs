namespace Luxbook.MVC.Infrastructure
{
    using System;
    using System.Collections.Generic;

    public interface ILanguageManager
    {
        string GetText<T>(T lookup);
    }

    public class LanguageManager : ILanguageManager
    {
        private readonly StringHelper _stringHelper;

        private static readonly Dictionary<string, string> EnumLookup = new Dictionary<string, string>
        {
            {"ComparisonType.FixedValue", "Fixed value"},
            {"RunnerTargetProperty.Lxb_Fw","Luxbet Fixed Win" },
            {"RunnerTargetProperty.Fx_Bob","Fixed win from Best of Best" },
            {"RunnerTargetProperty.Vic_Fw","TAB Fixed Win" },
            {"RunnerTargetProperty.Qld_Fw","UBET Fixed Win" },
            {"RunnerTargetProperty.Pm_Dvp","DVP" },
            {"RunnerTargetProperty.BFR_FW_L1","Betfair xL1" },
            {"RunnerTargetProperty.BFR_WAP","Betfair VWM" },
        };

        public LanguageManager(StringHelper stringHelper)
        {
            _stringHelper = stringHelper;
        }

        public string GetText<T>(T lookup)
        {
            var enumType = typeof(T);
            var enumName = Enum.GetName(enumType, lookup);
            var key = String.Format("{0}.{1}", enumType.Name, enumName);

            if (EnumLookup.ContainsKey(key))
            {
                return EnumLookup[key];
            }

            return   _stringHelper.SplitCamelCase(enumName);
        }

    }
}