using AutoMapper;
using FirebaseAdmin;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Threading.Tasks;

namespace NhapHangV2.API.Controllers.Auth
{
    [Route("api/authenticate")]
    [ApiController]
    [Description("Authenticate")]
    public class AuthController : NhapHangV2.BaseAPI.Controllers.Auth.AuthController
    {
        public AuthController(IServiceProvider serviceProvider, IConfiguration configuration, IMapper mapper, ILogger<AuthController> logger, FirebaseApp firebaseApp) : base(serviceProvider, configuration, mapper, logger, firebaseApp)
        {
        }
    }
}