import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const { deployments, getNamedAccounts } = hre;
  const { deploy, get } = deployments;
  const { deployer } = await getNamedAccounts();

  const CartesiCompute = await get("CartesiCompute");
  await deploy("DogecoinHash", {
    from: deployer,
    log: true,
    args: [CartesiCompute.address],
  });
};

export default func;
