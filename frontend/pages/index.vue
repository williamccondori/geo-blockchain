<template>
  <section>
    <h1 class="mb-1">SISTEMA INTEGRADO DE CATASTRO</h1>
    <el-divider />
    <el-card>
      <div id="map" />
    </el-card>
  </section>
</template>

<script>
import L from "leaflet";
import "leaflet/dist/leaflet.css";

export default {
  name: "IndexPage",
  data() {
    return {
      // Bloackchain
      account: null,
      registersContract: {},
    };
  },
  async mounted() {
    await this.initDApp();
    await this.initMap();
  },
  methods: {
    async initMap() {
      const map = L.map("map").setView([-0.23, -78.5], 13);
      // Add base map.
      map.addLayer(
        L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
          attribution: "&copy; WILLIAM CONDORI QUISPE",
        })
      );

      console.log(this.registersContract);
      const rCounter = await this.registersContract.registerCounter();
      console.log(rCounter);

      const registerCounter = rCounter.toNumber();
      for (let i = 1; i <= registerCounter; i++) {
        const register = await this.registersContract.registers(i);
        console.log(register);
      }
      console.log(registerCounter);
    },
    async initDApp() {
      if (window.ethereum) {
        // Accessing the provider through the ethereum object.
        const web3Provider = window.ethereum;
        const accounts = await web3Provider.request({
          method: "eth_requestAccounts",
        });
        this.account = accounts[0];
        // Load contract.
        const contracts = {};
        const response = await fetch("RegistersContract.json");
        // eslint-disable-next-line no-undef
        contracts.RegistersContract = TruffleContract(await response.json());
        contracts.RegistersContract.setProvider(web3Provider);
        this.registersContract = await contracts.RegistersContract.deployed();
      } else {
        this.$message.error(
          "NO SE HA ENCONTRADO LA EXTENSIÓN METAMASK, INSTALALA PARA PODER USAR LA APLICACIÓN"
        );
      }
    },
  },
};
</script>
