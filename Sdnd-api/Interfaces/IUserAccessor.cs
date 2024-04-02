using Sdnd_api.Dtos.Responses;
using Sdnd_api.Models;

namespace Sdnd_api.Interfaces;

public interface IUserAccessor
{
    CurrentUserDto GetCurrentUser();

}