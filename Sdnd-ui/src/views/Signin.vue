<script setup>
import { onBeforeUnmount, onBeforeMount, onMounted, computed } from "vue";
import { useStore } from "vuex";
import { ref } from "vue";
import { useRouter } from "vue-router";
import { required, email, minLength, sameAs, helpers } from "@vuelidate/validators";
import { useVuelidate } from "@vuelidate/core";
import ArgonInput from "@/components/ArgonInput.vue";
import ArgonButton from "@/components/ArgonButton.vue";


const body = document.getElementsByTagName("body")[0];
const router = useRouter();
const store = useStore();
const isSignUp = ref(false);
const successful = ref(false);
const message = ref("");
const IsLoading = ref(false);

const registerForm = ref({
  username: "",
  email: "",
  password: "",
  confirmPassword: ""
});

const loginData = ref({
  username: "",
  password: "",
});
const loginrules = {
  username: { required },
  password: { required }
}
const password = computed(() => registerForm.value.password);



function passwordComplexity(value) {
  // The password must contain at least one number, one lowercase letter, one uppercase letter, and one special character
  const passwordRegex = /^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*]).{6,}$/;
  return passwordRegex.test(value);
}
const rules = {
  username: { required, minLength: minLength(6) },
  email: { required, email },
  password: { required, minLength: minLength(8), passwordComplexity: helpers.withMessage('password must contain at least one number, one lowercase letter, one uppercase letter, and one special character', passwordComplexity) },
  confirmPassword: {
    required,
    sameAsPassword: sameAs(password),
  },
};
const loggedIn = computed(() => {
  return store.state.auth.status.loggedIn;
});

const v$ = useVuelidate(rules, registerForm);
const v1$ = useVuelidate(loginrules, loginData);
const handleRegisterSubmit = async () => {
  const isFormCorrect = await v$.value.$validate();
  if (isFormCorrect) {
    message.value = "";
    successful.value = false;
    try {
      IsLoading.value = true;
      const newUser = {
        username: registerForm.value.username,
        email: registerForm.value.email,
        password: registerForm.value.password,
      };
      console.log(newUser);
      const response = await store.dispatch("auth/register", newUser);

      console.log("Registration successful:", response.data);
      message.value = response.message;
      successful.value = true;
      IsLoading.value = true;
      isSignUp.value = false;

    } catch (error) {
      message.value =
        (error.response &&
          error.response.data &&
          error.response.data.message) ||
        error.message ||
        error.toString();
    } finally {
      IsLoading.value = false;
    }
  }
};
const login = async () => {
  const isFormCorrect = await v1$.value.$validate();
  if (isFormCorrect) {


    try {
      IsLoading.value = true;
      await store.dispatch("auth/login", loginData.value);
      IsLoading.value = false;
      router.push("/");
    } catch (error) {
      message.value = true;
      const errorMessage =
        (error.response && error.response.data && error.response.data.message) ||
        error.message ||
        error.toString();
      console.error(errorMessage);
    } finally {
      IsLoading.value = false;
    }
  }
};

// Lifecycle Hooks
onMounted(() => {
  if (loggedIn.value) {
    router.push("/profile");
  }
});

onBeforeMount(() => {
  store.state.hideConfigButton = true;
  store.state.showNavbar = false;
  store.state.showSidenav = false;
  store.state.showFooter = false;
  body.classList.remove("bg-gray-100");
});

onBeforeUnmount(() => {
  store.state.hideConfigButton = false;
  store.state.showNavbar = true;
  store.state.showSidenav = true;
  store.state.showFooter = true;
  body.classList.add("bg-gray-100");
});
</script>
<template>
  <div class="container mb-3" :class="{ 'right-panel-active': isSignUp }">
    <div
      class="form-container sign-in-container d-flex flex-column justify-content-center align-items-center text-center">
      <div class="d-flex flex-column justify-content-center align-items-center text-center"
        style="height: 70vh; width: 100%">
        <form @submit.prevent="login" style="width: 100%">
          <div class="pb-0 card-header text-start mb-3">
            <h5 class="font-weight-bold text-center">Sign In</h5>
            <p class="mb-0 text-center">
              Enter your username and password to sign in
            </p>
          </div>
          <div class="mb-2" style="width: 45%">
            <argon-input v-model="loginData.username" type="text" placeholder="Username" name="username" size="lg" />
            <p class="mb-1 p-0 validation" v-for="error of v1$.username.$errors" :key="error.$uid">
              {{ error.$property }} {{}} {{ error.$message.split(' ').slice(1).join(' ') }}
            </p>
          </div>
          <div class="mb-2" style="width: 45%">
            <argon-input v-model="loginData.password" type="password" placeholder="Password" name="password" width="50%"
              size="lg" />
            <p class="mb-1 p-0 validation" v-for="error of v1$.password.$errors" :key="error.$uid">
              {{ error.$property }} {{}} {{ error.$message.split(' ').slice(1).join(' ') }}
            </p>
          </div>
          <div class="text-center">
            <argon-button type="submit" class="mt-4" color="success" fullWidth size="lg">
              <span v-if="IsLoading" class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>
              <span v-else>Sign in</span>
            </argon-button>
          </div>
          <div class="px-1 pt-0 text-center card-footer px-lg-2 mt-1">
            <p class="mx-auto mb-4 text-sm">
              Don't have an account?
              <router-link class="nav-link me-2" to="/signup">
                <div @click.prevent="isSignUp = true" class="text-success font-weight-bold">
                  Sign up
                </div>
              </router-link>
            </p>
          </div>
        </form>
      </div>
    </div>
    <!-- Sign up form -->
    <div
      class="form-container sign-up-container d-flex flex-column justify-content-center align-items-center text-center">
      <div class="d-flex flex-column justify-content-center align-items-center text-center"
        style="height: 70vh; width: 100%">
        <form @submit.prevent="handleRegisterSubmit" style="width: 100%" novalidate>
          <div class="pb-0 card-header text-start mb-5">
            <h5 class="font-weight-bold text-center">Create An Account</h5>
            <p class="mb-0 text-center">
              Enter your username and email and password to create an account
            </p>
          </div>
          <div class="mb-2" style="width: 45%">
            <ArgonInput class="mb-1" id="name" type="text" placeholder="Name" aria-label="Name"
              v-model="registerForm.username" />
            <p class="m-0 p-0 validation" v-for="error of v$.username.$errors" :key="error.$uid">
              {{ error.$property }} {{}} {{ error.$message.split(' ').slice(1).join(' ') }}
            </p>
          </div>
          <div class="mb-2" style="width: 45%">
            <ArgonInput class="mb-1" id="email" type="email" placeholder="Email" aria-label="Email"
              v-model="registerForm.email" />
            <p class="m-0 p-0 validation" v-for="error of v$.email.$errors" :key="error.$uid">
              {{ error.$property }} {{}} {{ error.$message.split(' ').slice(1).join(' ') }}
            </p>
          </div>
          <div class="mb-3" style="width: 45%">
            <ArgonInput class="mb-1" id="password" type="password" placeholder="Password" aria-label="Password"
              v-model="registerForm.password" />
            <p class="m-0 p-0 validation" v-for="error of v$.password.$errors" :key="error.$uid">
              {{ error.$property }} {{}} {{ error.$message.split(' ').slice(1).join(' ') }}
            </p>
          </div>
          <div class="mb-3" style="width: 45%">
            <ArgonInput class="mb-1" id="password" type="password" placeholder="Confirm Your Password"
              aria-label="Password" v-model="registerForm.confirmPassword" />
            <p class="m-0 p-0 validation" v-for="error of v$.confirmPassword.$errors" :key="error.$uid">
              {{ error.$property }} {{}} {{ error.$message.split(' ').slice(1).join(' ') }}
            </p>
          </div>

          <div class="text-center">
            <argon-button type="submit" color="success" fullWidth size="lg">
              <span v-if="IsLoading" class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>
              <span v-else>Sign
                up</span></argon-button>
          </div>
          <div class="px-1 pt-0 text-center card-footer px-lg-2 mt-1">
            <p class="mx-auto mb-4 text-sm">
              Already have an account?
              <router-link class="nav-link me-2" to="/signup">
                <div @click.prevent="isSignUp = false" class="text-success font-weight-bold">
                  Sign in
                </div>
              </router-link>
            </p>
          </div>
        </form>
      </div>
    </div>
    <div class="overlay-container">
      <div class="overlay my-3 d-flex">
        <div style="flex-grow: 1; margin-left: 20px; margin-top: 130px">
          <img class="w-full" src="authentication.png" alt="authentication" />
        </div>
        <span class="mx-7"></span>
        <div style="flex-grow: 1; margin-top: 130px">
          <img class="w-full" src="authentication.png" alt="authentication" />
        </div>
      </div>
    </div>
  </div>
</template>
<style scoped>
@import url("https://fonts.googleapis.com/css?family=Montserrat:400,800");

h1 {
  font-weight: bold;
  margin: 0;
}

h2 {
  text-align: center;
}

p {
  font-size: 14px;
  font-weight: 100;
  line-height: 20px;
  letter-spacing: 0.5px;
  margin: 20px 0 30px;
}

span {
  font-size: 12px;
}

a {
  color: #333;
  font-size: 14px;
  text-decoration: none;
  margin: 15px 0;
}

button {
  transition: transform 80ms ease-in;
}

button:active {
  transform: scale(0.95);
}

button:focus {
  outline: none;
}

button.ghost {
  background-color: transparent;
}

form {
  background-color: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-direction: column;
  padding: 0 50px;
  height: 100%;
  text-align: center;
}

.container {
  background-color: #fff;
  border-radius: 10px;
  overflow: hidden;
  margin: 0px;
  height: 95vh;
  width: 90vw;
}

.form-container {
  position: absolute;
  top: 0;
  height: 100%;
  transition: all 0.6s ease-in-out;
}

.sign-in-container {
  left: 0;
  width: 50%;
  z-index: 2;
}

.container.right-panel-active .sign-in-container {
  transform: translateX(100%);
}

.sign-up-container {
  left: 0;
  width: 50%;
  opacity: 0;
  z-index: 1;
}

.container.right-panel-active .sign-up-container {
  transform: translateX(100%);
  opacity: 1;
  z-index: 5;
  animation: show 0.6s;
}

@keyframes show {

  0%,
  49.99% {
    opacity: 0;
    z-index: 1;
  }

  50%,
  100% {
    opacity: 1;
    z-index: 5;
  }
}

.overlay-container {
  position: absolute;
  top: 0;
  left: 50%;
  width: 49%;
  height: 100%;
  overflow: hidden;
  transition: transform 0.6s ease-in-out;
  z-index: 100;
}

.container.right-panel-active .overlay-container {
  transform: translateX(-100%);
}

.overlay {
  background: #f5d246;
  background: -webkit-linear-gradient(to right, #c0a538, #f5d246);
  background: linear-gradient(to right, #c0a538, #f5d246);
  background-repeat: no-repeat;
  background-size: cover;
  background-position: 0 0;
  border-radius: 15px;
  color: #ffffff;
  position: relative;
  left: -100%;
  height: 100vh;
  width: 200%;
  transform: translateX(0);
  transition: transform 0.6s ease-in-out;
}

.container.right-panel-active .overlay {
  transform: translateX(50%);
}

.overlay-panel {
  position: absolute;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-direction: column;
  padding: 0 40px;
  text-align: center;
  top: 0;
  height: 100%;
  width: 50%;
  transform: translateX(0);
  transition: transform 0.6s ease-in-out;
}

.overlay-left {
  transform: translateX(-20%);
}

.container.right-panel-active .overlay-left {
  transform: translateX(0);
}

.overlay-right {
  right: 0;
  transform: translateX(0);
}

.container.right-panel-active .overlay-right {
  transform: translateX(20%);
}

.validation {
  color: rgba(255, 0, 0, 0.781);
  font-size: small;
  text-align: start;
}
</style>
