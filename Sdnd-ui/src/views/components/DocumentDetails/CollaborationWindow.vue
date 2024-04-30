<template>
    <div v-if="sharedUsers.length">
        <div v-for="user in sharedUsers" :key="user.id" class="shared-user">
            <div class="profile-image"
                :style="user.profileImageUrl ? `background-image: url(${user.profileImageUrl})` : `background-color: #007bff`">
                <span v-if="!user.profileImageUrl">{{ user.username[0].toUpperCase() }}</span>
            </div>
            <!-- <img :src="user.profileImageUrl || 'defaultProfilePicture.png'" alt="User profile image"
                class="profile-image"> -->
            <div class="user-info">
                <h3>{{ user.username }}</h3>
                <p>Added on: {{ user.addedDate }}</p>
            </div>
            <span class="user-role mx-0 mt-2 d-flex align-items-center">
                <p>{{ user.role }}</p>
                <i class="fas fa-angle-down mb-3 mx-2"></i>
            </span>
            <!-- <span class="action-icon" @click="toggleDropdown(user.id)">
                <i class="fas fa-ellipsis-v"></i>
            </span>
            <div v-if="dropdownUserId === user.id" class="dropdown-menu">
                <button @click="revokeAccess(user.id)">Revoke Access</button>
                <--Add more actions as needed -->
        </div>
    </div>

    <div class="share-form">
        <!-- Step 1: Select user -->
        <div class="first-step" v-if="step === 1">
            <label for="username"> Who do you wanna collaborate with :</label>
            <AutoComplete class="user-input" v-model="selectedUser" :suggestions="usernames" @complete="fetchUsernames"
                placeholder="Enter a username" />
            <!-- <input type="text" id="username" v-model="selectedUser" @input="filterUsernames"> -->
            <button style="height: 40px; width: 280px; font-size: large" @click="step = 2">Next</button>
        </div>

        <!-- Step 2: Select role -->
        <div class="second-step" v-if="step === 2">
            <label for="selectedUser">Selected User:</label>
            <input type="text" id="selectedUser" v-model="selectedUser" disabled>
            <label for="role">Select a role:</label>
            <Dropdown v-model="selectedRole" :options="roles" optionLabel="name" placeholder="Please Select a Role"
                class="w-full md:w-14rem" />
            <div class="d-flex button-container">
                <button @click="step = 1" class="styled-button">
                    <i class="fas fa-arrow-left"></i> Back
                </button>
                <button @click="shareDocument" class="styled-button">
                    <i class="fas fa-share"></i> Share
                </button>
            </div>
        </div>
    </div>
</template>

<script setup>
import AutoComplete from 'primevue/autocomplete';
import { ref, computed, onMounted } from 'vue';
import { useStore } from 'vuex';
import Dropdown from 'primevue/dropdown';
import { toast } from "vue3-toastify";
import BaseApiService from '../../../services/apiService';
const store = useStore();
const sharedUsername = ref('');
const shareResult = ref('');
const usernames = ref([]);
const documentId = computed(() => store.state.documentId);
const filteredUsernames = ref([]);

const step = ref(1);
const selectedUser = ref('');
const selectedRole = ref('');
const roles = ref([
    { icon: 'fas fa-eye', name: 'Viewer', code: 'Vi' },
    { icon: 'fa-solid fa-pencil', name: 'Editor', code: 'Ed' }
]);
// Other reactive properties...



const fetchUsernames = async () => {
    try {
        const response = await BaseApiService(`Account/usernames`).list();
        console.log(response.data);
        usernames.value = response.data;
    } catch (error) {
        console.error('Error fetching usernames:', error);
    }
};

const selectUsername = username => {
    sharedUsername.value = username;
    filteredUsernames.value = [];
};
const sharedUsers = ref([
    {
        id: 1,
        username: 'John Doe',
        addedDate: '2022-01-01',
        role: 'Owner',
        profileImageUrl: 'https://randomuser.me/api/portraits/men/1.jpg'
    },
    {
        id: 2,
        username: 'Jane Smith',
        addedDate: '2022-01-15',
        role: 'Viewer',
        profileImageUrl: 'https://randomuser.me/api/portraits/women/2.jpg'
    },
    {
        id: 3,
        username: 'Robert Johnson',
        addedDate: '2022-02-01',
        role: 'Editor',
        profileImageUrl: 'https://randomuser.me/api/portraits/men/3.jpg'
    }, {
        id: 4,
        username: 'Robert Johnson',
        addedDate: '2022-02-01',
        role: 'Viewer',


    },
    // Add more sample shared users as needed
]);
const shareDocument = async () => {
    try {
        const newDoc = { documentId: documentId.value, username: sharedUsername.value };
        const response = await BaseApiService('Document/Share').create(newDoc);
        shareResult.value = response.data;

        // Use the toast object to show a success message
        toast.success("Document Shared Successfully !", {
            duration: 1000, // Auto-close duration in milliseconds
            position: "bottom-right", // Position of the toast message
        });
        step.value = 1;
    } catch (error) {
        shareResult.value = 'Error sharing document';
        console.error('Error sharing document:', error);
    }
};
onMounted(fetchUsernames);
</script>

<style lang="scss" scoped>
.shared-user {
    display: flex;
    align-items: center;
    justify-content: space-between;
    background-color: #f5f5f5;
    padding: 10px;
    border-radius: 5px;
    margin-bottom: 10px;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.15);
    position: relative;
}


.profile-image {
    width: 50px;
    height: 50px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    background-size: cover;
    background-position: center;
    color: #fff;
    font-size: 20px;
    font-weight: bold;
    margin-right: 10px;
}

.user-info {
    display: flex;
    flex-direction: column;
    flex-grow: 1;
}

.user-info h3 {
    margin: 0;
    font-size: 16px;
    font-weight: 600;
    color: #000;
}

.user-info p {
    margin: 0;
    font-size: 14px;
    color: #666;
}

.action-icon {
    cursor: pointer;
    color: #666;
}

// .share-form {
//     display: flex;
//     flex-direction: column;
//     width: 300px;
//     margin: auto;
// }

.share-form label {
    margin-top: 10px;
    font-size: 15px;
    font-weight: 450;
    color: #474747;
}

.user-input {
    background-color: #f5f5f5;
    color: #000;
}

.share-form button {
    background-color: #0058b6;
    color: #fff;
    border: none;
    padding: 5px 10px;
    margin-top: 15px;
    cursor: pointer;
    border-radius: 5px;
    transition: background-color 0.3s ease;

    &:hover {
        background-color: #00448b;
    }
}

// .share-form button:hover {
//     background-color: #45a049;
// }

// .autocomplete-dropdown {
//     border: 1px solid #ccc;
//     border-radius: 4px;
//     padding: 5px;
//     margin-top: 5px;
// }

// .autocomplete-dropdown div {
//     padding: 5px;
//     cursor: pointer;
// }

// .autocomplete-dropdown div:hover {
//     background-color: #f1f1f1;
// }



.share-form {
    // display: flex;
    // align-items: center;
    // justify-content: space-between;
    width: 100%;
    background-color: #f5f5f5;
    padding: 10px 50px 20px;
    border-radius: 5px;
    margin-top: 20px;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.15);
}








.first-step,
.second-step {
    display: flex;
    flex-direction: column;
    margin: 0 138px;
}

.button-container {
    display: flex;
    justify-content: space-between;
    width: 100%;
}

.styled-button {
    flex: 1;
    height: 40px;
    margin: 5px;
    padding: 10px;
    border: none;
    border-radius: 4px;
    background-color: #4CAF50;
    color: white;
    cursor: pointer;
    text-align: center;
}

.styled-button:hover {
    background-color: #45a049;
}

.styled-button i {
    margin-right: 5px;
}

// .dropdown-menu {
//     position: absolute;
//     right: 0;
//     top: 100%;
//     background-color: #fff;
//     border: 1px solid #ccc;
//     border-radius: 5px;
//     padding: 10px;
//     z-index: 1;
// }

// .shared-user {
//     display: flex;
//     align-items: center;
//     margin-bottom: 20px;
// }


.autocomplete-dropdown {
    position: absolute;
    background-color: white;
    border: 1px solid #ccc;
    max-height: 150px;
    overflow-y: auto;
}

.autocomplete-dropdown div {
    padding: 5px;
    cursor: pointer;
}
</style>