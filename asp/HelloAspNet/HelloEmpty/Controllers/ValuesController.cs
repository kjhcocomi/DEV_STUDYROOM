using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using HelloEmpty.Models;
using System.Collections.Generic;

namespace HelloEmpty.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ValuesController : ControllerBase
    {
        [HttpGet]
        public List<HelloMessage> Get()
        {
            List<HelloMessage> messages = new List<HelloMessage>();
            messages.Add(new HelloMessage() { Message = "Hello Web API 1 !" });
            messages.Add(new HelloMessage() { Message = "Hello Web API 2 !" });
            messages.Add(new HelloMessage() { Message = "Hello Web API 3 !" });

            return messages;
        }
    }
}
