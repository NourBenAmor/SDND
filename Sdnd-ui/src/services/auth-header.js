export default function authHeader() {
  let user = JSON.parse(localStorage.getItem("user"));

  if (user && user.token) {
    console.log("useraccestoken", user.token);
    return {
      Authorization: "Bearer " + user.token,
    };
  } else {
    return {};
  }
}
