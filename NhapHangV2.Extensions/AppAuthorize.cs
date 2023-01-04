using NhapHangV2.Interface.Services;
using NhapHangV2.Utilities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Controllers;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authentication;
using System.Diagnostics;

namespace NhapHangV2.Extensions
{
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = true, Inherited = true)]
    public class AppAuthorize : AuthorizeAttribute, IAuthorizationFilter
    {
        private readonly int[] Permissions;
        private readonly string ControllerName;

        public AppAuthorize(int[] permissions, string controllerName = "")
        {
            Permissions = permissions;
            ControllerName = controllerName;
        }

        public void OnAuthorization(AuthorizationFilterContext context)
        {
            var user = (UserLoginModel)context.HttpContext.Items["User"];//.User;
            string controllerName = string.Empty;
            if (!string.IsNullOrEmpty(ControllerName))
                controllerName = ControllerName;
            else if (context.ActionDescriptor is ControllerActionDescriptor descriptor)
            {
                controllerName = descriptor.ControllerName;
            }

            if (user == null)
            {
                context.Result = new JsonResult(new AppDomainResult()
                {
                    ResultCode = (int)HttpStatusCode.Unauthorized,
                    ResultMessage = "Unauthorized"
                });
                return;
            }
            var expirationTime = DateTimeOffset.FromUnixTimeSeconds(long.Parse(context.HttpContext.User.Claims.ElementAt(2).Value)).DateTime;

            if ((DateTime.UtcNow.AddHours(7).AddMinutes(1)) > expirationTime)
            {
                context.Result = new JsonResult(new AppDomainResult()
                {
                    ResultCode = (int)HttpStatusCode.Unauthorized,
                    ResultMessage = "Phiên đăng nhập hết hạn, vui lòng đăng nhập lại"
                });
                return;
            }

            IUserService userService = (IUserService)context.HttpContext.RequestServices.GetService(typeof(IUserService));
            IConfiguration configuration = (IConfiguration)context.HttpContext.RequestServices.GetService(typeof(IConfiguration));
            var hasPermit = false;
            var appSettingsSection = configuration.GetSection("AppSettings");
            var appSettings = appSettingsSection.Get<AppSettings>();
            if (appSettings != null && appSettings.GrantPermissionDebug)
            {
                hasPermit = true;
            }
            else
            {
                var userCheckResult = userService.HasPermission(LoginContext.Instance.CurrentUser.UserId, controllerName, Permissions);
                hasPermit = userCheckResult.Result;
            }

            if (!hasPermit)
            {
                context.Result = new JsonResult(new AppDomainResult()
                {
                    ResultCode = (int)HttpStatusCode.Unauthorized,
                    ResultMessage = "Bạn không có quyền thực hiện thao tác này"
                });
                throw new UnauthorizedAccessException();
            }

        }
    }
}
