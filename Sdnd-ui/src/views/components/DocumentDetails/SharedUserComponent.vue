<template>
    <div class="userHeader">

        <div class="profile-image"
            :style="user.profilePictureUrl ? `background-image: url(${user.profilePictureUrl})` : `background-color: #007bff`">
            <span v-if="!user.profilePictureUrl">
                {{ user.username[0].toUpperCase() }}
            </span>
        </div>
        <!-- <img :src="user.profilePictureUrl || 'defaultProfilePicture.png'" alt="User profile image"
                class="profile-image"> -->
        <div class="user-info">
            <h3>{{ user.username }}</h3>
            <p>{{ user.email }}</p>
            <!-- <p>Added on: {{ user.addedDate }}</p> -->
        </div>
        <span class="user-role mx-0 mt-2 d-flex align-items-center" @click="showUserDetails = !showUserDetails">
            {{ showUserDetails ? 'hide' : 'show' }}

            <i :class="showUserDetails ? 'fas fa-angle-up mt-0 mx-2' : 'fas fa-angle-down mt-0 mx-2'"></i>
        </span>
    </div>
    <div v-if="showUserDetails" class="userContent">
        <div class="user-permissions"></div>
        <h4>{{ user.username }}'s Permissions</h4>
        <div class="d-flex my-4">
            <div v-for="permission in user.permissions" :key="permission" class="m-0 p-0">
                <Tag v-if="permission == 1" value="view" severity="success" class="mx-2" />
                <Tag v-if="permission == 2" value="edit" severity="warning" class="mx-2" />
                <Tag v-if="permission == 3" value="share" severity="info" class="mx-2" />
            </div>
        </div>
        <div class="user-tasks" v-if="user.tasks && user.tasks.length > 0">
            <h4>{{ user.username }}'s Tasks</h4>
            <div class="user-Task" v-for="task in user.tasks" :key="task.id">
                <p class="fs-10 mb-0">{{ task.description }}</p>
                <Tag v-if="task.state == 0" value="Pending" severity="warning" class="mx-2" />
                <Tag v-if="task.state == 2" value="Completed" severity="success" class="mx-2" />
                <Tag v-if="task.state == 1" value="In Progress" severity="info" class="mx-2" />
            </div>
        </div>
        <button v-if="isAuthor" class="revoke-button" @click="revokeAccess(user.id)">
            <i class="fas fa-user-times"></i> Revoke Access
        </button>
    </div>
    <!-- <p>{{ user.role }}</p> -->
    <!-- <span class="action-icon" @click="toggleDropdown(user.id)">
                <i class="fas fa-ellipsis-v"></i>
            </span>
            <div v-if="dropdownUserId === user.id" class="dropdown-menu">
                <button @click="revokeAccess(user.id)">Revoke Access</button>
                <--Add more actions as needed -->
</template>

<script setup>

import Tag from 'primevue/tag';
import { watch, ref, computed } from 'vue';
import { useRoute } from 'vue-router';
import { useStore } from 'vuex';
import BaseApiService from '../../../services/apiService';
const store = useStore();
const DocumentId = computed(() => store.state.documentId);
const route = useRoute();
const isAuthor = ref(false);
isAuthor.value = route.path.includes('/tables');


const showUserDetails = ref(false);
const props = defineProps({
    user: Object
})
const emit = defineEmits(['refetchUsers']);
watch(props, () => {
    console.log(props.user)
})

const revokeAccess = async (userId) => {
    const doc = {
        documentId: DocumentId.value,
        userId: userId
    }
    console.log('Revoking access for user:', userId);
    console.log('Document ID:', DocumentId.value);
    await BaseApiService('Document/RevokeAccess').removeObj(doc).then(response => {
        console.log('Access revoked:', response);
        emit('refetchUsers');

    }).catch(error => {
        console.error('Error revoking access:', error);
    });
}

</script>

<style lang="scss" scoped>
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

.user-tasks {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 10px;
    border-radius: 5px;
    margin-top: 10px;
    background-color: #f9f9f9;
    width: 80%;
}

.user-Task {
    display: flex;
    width: 80%;
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    padding: 10px 20px;
    border: 1px solid #ccc;
    border-radius: 5px;
    margin-top: 10px;
    background-color: #f9f9f9;
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

.revoke-button {
    padding: 5px 10px;
    border: 1px solid #ccc;
    border-radius: 5px;
    background-color: #f9f9f9;
    color: #000;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    position: relative;
    top: 0;
    right: 0;
}

h4 {
    margin: 0;
    font-size: 16px;
    font-weight: 600;
    color: #666;
}

.user-info p {
    margin: 0;
    font-size: 14px;
    color: #666;
}

.userHeader {
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.userContent {
    display: flex;
    align-items: center;
    flex-direction: column;
    padding: 10px;
    border: 1px solid #ccc;
    border-radius: 5px;
    margin-top: 10px;
    background-color: #f9f9f9;
}
</style>