<template>
  <div>
    <table class="table border">
        <template v-if="Object.keys(inner).length > 0">
          <tr class="header border">
            <th scope="col">ID</th>
            <th scope="col">Distance</th>
            <th scope="col">Velocity</th>
            <th scope="col">Trajectory</th>
            <th scope="col">Scan Status</th>
          </tr>
          <tr v-for="(obj, id) in inner" :key="id" class="item border">
            <td>{{id}}</td>
            <td>{{obj.dist}} KM</td>
            <td>{{obj.vel}} KM/S</td>
            <td>{{computeTrajectory(obj.traj)}}</td>
            <td>{{obj.scan_stat ? "Scanned" : "Not Scanned"}}</td>
          </tr>
        </template>
        <tr v-else>
          <td colspan="5">Unable to locate any objects in the vicinity.</td>
        </tr>
    </table>
  </div>
</template>

<script>
export default {
  data() {
    return this.$root.$data.state;
  },
  methods: {
      computeTrajectory(traj) {
          return traj ? "On a collision course" : "On an escape trajectory";
      }
  }
}
</script>

<style lang="scss" scoped>
table {
    width: 100%;
    text-align: center;
}
tr {
  line-height: 135%;
}
</style>
