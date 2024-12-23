import mongoose from "mongoose";

const urlDeployment =
  "mongodb+srv://nhoccuthien0538:thienvip123@cluster0.w9owtoc.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";

export default async function connect() {
  try {
    await mongoose.connect(urlDeployment, {
      useNewUrlParser: true,
      useUnifiedTopology: true
    });
    console.log("Connect Successfully !!");
  } catch (error) {
    console.log("Connect failed !!");
  }
}
