namespace Luxbook.MVC.App_Start
{
    using System;
    using System.Web;
    using Microsoft.Practices.ServiceLocation;
    using Microsoft.Practices.Unity;
    using RubixRacing.Cache;
    using Unity.AutoRegistration;

    /// <summary>
    ///     Specifies the Unity configuration for the main container.
    /// </summary>
    public class UnityConfig
    {
        /// <summary>Registers the type mappings with the Unity container.</summary>
        /// <param name="container">The unity container to configure.</param>
        /// <remarks>
        ///     There is no need to register concrete types such as controllers or API controllers (unless you want to
        ///     change the defaults), as Unity allows resolving a concrete type even if it was not previously registered.
        /// </remarks>
        public static void RegisterTypes(IUnityContainer container)
        {
            // NOTE: To load from web.config uncomment the line below. Make sure to add a Microsoft.Practices.Unity.Configuration to the using statements.
            // container.LoadConfiguration();

            // TODO: Register your types here
            // container.RegisterType<IProductRepository, ProductRepository>();
            container.ConfigureAutoRegistration()
                .ExcludeSystemAssemblies()
                // If you have an interface IFoo, and a class Foo : IFoo, Foo will automatically be bound to IFoo in Unity
                .Include(If.ImplementsITypeName, Then.Register())
                .ApplyAutoRegistration();


            container.RegisterType<HttpContextBase, HttpContextWrapper>(new InjectionFactory(c => (object) GetHttpContextBase()));
            container.RegisterInstance<ICacheProvider>(new InMemoryCacheProvider());
        }

        private static HttpContextBase GetHttpContextBase()
        {
            if (HttpContext.Current != null)
            {
                return new HttpContextWrapper(HttpContext.Current);
            }
            return null;
        }

        #region Unity Container

        private static readonly Lazy<IUnityContainer> Container = new Lazy<IUnityContainer>(() =>
        {
            var container = new UnityContainer();
            RegisterTypes(container);
            var unityServiceLocator = new UnityServiceLocator(container);

            ServiceLocator.SetLocatorProvider(() => unityServiceLocator);

            return container;
        });

        /// <summary>
        ///     Gets the configured Unity container.
        /// </summary>
        public static IUnityContainer GetConfiguredContainer()
        {
            return Container.Value;
        }

        #endregion
    }
}