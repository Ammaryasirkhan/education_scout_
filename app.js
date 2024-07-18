const express = require("express");
const mysql = require("mysql");
const nodemailer = require("nodemailer");
const bodyParser = require("body-parser");
const multer = require("multer");
const fs = require("fs");
const app = express();

const cors = require("cors");
app.use(cors());

// Configure storage for uploaded files
const storage = multer.memoryStorage(); // Store uploaded files in memory
const upload = multer({ dest: "uploads/" });

// app.use(express.urlencoded({extended: true}));
// app.use(express.json());
app.use(bodyParser.json({ limit: "50mb" }));
app.use(bodyParser.urlencoded({ limit: "50mb", extended: true }));
const port = 1000;
const ipAddress = "192.168.43.219";

var con = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: null,
  database: "education.",
});

con.connect(function (err) {
  if (err) throw err;
  console.log("Connected!");
});

app.get("/", (req, res) => {
  res.send("Data Base Getting");
});

app.get("/getfeedback", (req, res) => {
  con.query("SELECT * FROM feedback", function (err, result, fields) {
    if (err) throw err;
    res.send(result);
  });
});
app.get("/getStudents", (req, res) => {
  con.query("SELECT * FROM student", function (err, result, fields) {
    if (err) throw err;
    res.send(result);
  });
});

// Forgot Password
app.post("/forgot-password", (req, res) => {
  const email = req.body.email;
  const token = crypto.randomBytes(20).toString("hex");

  const sql = "INSERT INTO password_reset_tokens (email, token) VALUES (?, ?)";
  con.query(sql, [email, token], (err) => {
    if (err) {
      return res.status(500).json({ message: "Database error" });
    }

    // Send an email with the reset link
    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: "ammaryasirkhan5@gmail.com",
        pass: "jqrs oywz uumb wxkt",
      },
    });

    const mailOptions = {
      from: "ammaryasirkhan5@gmail.com",
      to: "ammaryasirniazi567@gmail.com",
      subject: "Password Reset",
      text: `Click the following link to reset your password: https://your-app-url/reset-password/${token}`,
    };

    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        return res.status(500).json({ message: "Email sending error" });
      }
      res.json({ message: "Password reset email sent" });
    });
  });
});

// Reset the password
app.post("/reset-password/:token", (req, res) => {
  const token = req.params.token;
  const newPassword = req.body.newPassword;

  const sql =
    "UPDATE users SET password = ? WHERE email = (SELECT email FROM password_reset_tokens WHERE token = ?)";
  con.query(sql, [newPassword, token], (err, result) => {
    if (err || result.affectedRows === 0) {
      return res.status(400).json({ message: "Invalid or expired token" });
    }
    res.json({ message: "Password reset successful" });
  });
});

app.get("/countstudents", (req, res) => {
  con.query(
    "SELECT COUNT(*) AS studentCount FROM student",
    function (err, result, fields) {
      if (err) throw err;
      const studentCount = result[0].studentCount; // Extract the student count from the result
      res.send({ studentCount });
    }
  );
});
app.get("/countschools", (req, res) => {
  con.query(
    "SELECT COUNT(*) AS schoolCount FROM school",
    function (err, result, fields) {
      if (err) throw err;
      const schoolCount = result[0].schoolCount; // Extract the student count from the result
      res.send({ schoolCount });
    }
  );
});

app.get("/getdoc", (req, res) => {
  con.query("SELECT * FROM doc", function (err, result, fields) {
    if (err) throw err;
    res.send(result);
  });
});
// search query
app.get("/searchSchool", (req, res) => {
  const query = req.query.query;

  if (!query) {
    return res
      .status(400)
      .json({ message: 'Query parameter "query" is required.' });
  }

  const sql = `
    SELECT School_ID, School_Name, Email, Contact, address, Profile_image,
    head, head_qualification, teacher1, teacher1_qualification, teacher1_designation,
    teacher2, teacher2_qualification, teacher2_designation
    FROM school
    WHERE School_Name LIKE ? OR address LIKE ?
  `;

  const searchQuery = `%${query}%`;

  con.query(sql, [searchQuery, searchQuery], (err, results) => {
    if (err) {
      console.log("Database error:", err);
      return res.status(500).json({ message: "Internal Server Error" });
    }

    res.status(200).json(results);
  });
});

app.post("/createNewAccount", (req, res) => {
  var userData = req.body;
  var userName = userData?.name;
  var userEmail = userData?.email;
  var userPassword = userData?.password;
  var userId = Math.floor(Math.random() * 10000) + 1;

  // Check if email already exists
  var checkEmailSql = "SELECT * FROM `student` WHERE `Email` = ?";
  con.query(checkEmailSql, [userEmail], function (err, result, fields) {
    if (err) {
      console.log("Error checking email:", err);
      res.status(500).send("Internal Server Error");
      return;
    }

    if (result.length > 0) {
      res.status(400).send("Email already exists");
      return;
    }

    // Insert new account
    var insertSql =
      "INSERT INTO `student` (`Student_ID`, `Student_Name`, `Email`, `password`) VALUES (?, ?, ?, ?)";
    con.query(
      insertSql,
      [userId, userName, userEmail, userPassword],
      function (err, result, fields) {
        if (err) {
          console.log("Error creating account:", err);
          res.status(500).send("Internal Server Error");
          return;
        }

        res.status(200).send({ message: "Account Created Successfully." });
      }
    );
  });
});

// gt API for myaccount

app.get("/myAccount", (req, res) => {
  var userEmail = req.query.email;

  // Retrieve user account information from the database based on the provided email
  var selectUserSql =
    "SELECT Student_Name, Email, password, Registration_Date FROM `student` WHERE `Email` = ?";
  con.query(selectUserSql, [userEmail], function (err, result, fields) {
    if (err) {
      console.log("Error retrieving user account:", err);
      res.status(500).send("Internal Server Error");
      return;
    }

    if (result.length === 0) {
      res.status(404).send("User not found");
      return;
    }

    var user = result[0];

    // Prepare the response object with the user's information
    var response = {
      username: user.Student_Name,
      email: user.Email,
      password: user.password,
      registrationDate: user.Registration_Date,
      // Add other fields as needed
    };

    res.status(200).send(response);
  });
});
app.get("/my", (req, res) => {
  var userEmail = req.query.email;

  // Retrieve user account information from the database based on the provided email
  var selectUserSql = "SELECT Student_Name FROM `student` WHERE `Email` = ?";
  con.query(selectUserSql, [userEmail], function (err, result, fields) {
    if (err) {
      console.log("Error retrieving user account:", err);
      res.status(500).send("Internal Server Error");
      return;
    }

    if (result.length === 0) {
      res.status(404).send("User not found");
      return;
    }

    var user = result[0];

    // Prepare the response object with the user's information
    var response = {
      username: user.Student_Name,
      // Add other fields as needed
    };

    res.status(200).send(response);
  });
});

// for school acount
app.get("/schoolAccount", (req, res) => {
  var schoolEmail = req.query.email;

  // Retrieve school account information from the database based on the provided email
  var selectSchoolSql =
    "SELECT School_Name, Email, password,Registration_Date FROM `school` WHERE `Email` = ?";
  con.query(selectSchoolSql, [schoolEmail], function (err, result, fields) {
    if (err) {
      console.log("Error retrieving school account:", err);
      res.status(500).send("Internal Server Error");
      return;
    }

    if (result.length === 0) {
      res.status(404).send("School not found");
      return;
    }

    var school = result[0];

    // Prepare the response object with the school's information
    var response = {
      schoolId: school.School_ID,
      schoolName: school.School_Name,
      email: school.Email,
      contact: school.Contact,
      address: school.address,
      profileImage: school.Profile_image,
      password: school.password,
      license: school.License,
      registrationDate: school.Registration_Dtae,
      // Add other fields as needed
    };

    res.status(200).send(response);
  });
});
app.get("/combine", (req, res) => {
  var userEmail = req.query.email;

  // Check if the email exists in the student table
  var selectStudentSql =
    "SELECT Student_Name AS name, Email AS email, password, Registration_Date AS registrationDate FROM `student` WHERE `Email` = ?";
  con.query(
    selectStudentSql,
    [userEmail],
    function (err, studentResult, fields) {
      if (err) {
        console.log("Error retrieving student account:", err);
        res.status(500).send("Internal Server Error");
        return;
      }

      // If the email exists in the student table, return the student's information
      if (studentResult.length > 0) {
        var student = studentResult[0];
        var response = {
          userType: "student",
          name: student.name,
          email: student.email,
          password: student.password,
          registrationDate: student.registrationDate,
          // Add other fields as needed
        };
        res.status(200).send(response);
      } else {
        // If the email is not found in the student table, check the school table
        var selectSchoolSql =
          "SELECT School_ID, School_Name AS name, Email AS email, password, Registration_Date AS registrationDate, Contact AS contact, address FROM `school` WHERE `Email` = ?";
        con.query(
          selectSchoolSql,
          [userEmail],
          function (err, schoolResult, fields) {
            if (err) {
              console.log("Error retrieving school account:", err);
              res.status(500).send("Internal Server Error");
              return;
            }

            // If the email exists in the school table, return the school's information
            if (schoolResult.length > 0) {
              var school = schoolResult[0];

              // Now, fetch feedback data for the school
              var schoolId = school.School_ID;

              // Now, fetch feedback data for the school using its ID
              var selectFeedbackSql =
                "SELECT  Feedback_text FROM `feedback` WHERE `School_ID` = ?";
              con.query(
                selectFeedbackSql,
                [schoolId],
                function (err, feedbackResult, fields) {
                  if (err) {
                    console.log("Error retrieving feedback:", err);
                    res.status(500).send("Internal Server Error");
                    return;
                  }

                  var response = {
                    userType: "school",
                    name: school.name,
                    email: school.email,
                    feedback: feedbackResult, // Include feedback data
                    password: school.password,
                    registrationDate: school.registrationDate,
                    contact: school.contact,
                    address: school.address,
                    // Add other fields as needed
                  };
                  res.status(200).send(response);
                }
              );
            } else {
              // If the email is not found in either table, return a not found response
              res.status(404).send("Account not found");
            }
          }
        );
      }
    }
  );
});

// Fetching account

app.get("/api/school/profile/:schoolId", (req, res) => {
  const schoolId = req.params.schoolId;

  // Query to fetch school information from the school table
  const selectSchoolSql =
    "SELECT School_ID, School_Name, Email, Contact, address, Profile_image, password, License, Registration_Date, status FROM `school` WHERE School_ID = ?";
  con.query(selectSchoolSql, [schoolId], function (err, schoolResult, fields) {
    if (err) {
      console.log("Error retrieving school information:", err);
      res.status(500).send("Internal Server Error");
      return;
    }

    if (schoolResult.length === 0) {
      res.status(404).send("School not found");
      return;
    }

    const school = schoolResult[0];

    // Query to fetch documents related to the school from the doc table
    const selectDocumentsSql =
      "SELECT Docum_ID, School_ID, Description, prospectus_document, Admission_document, building_images, Teachers FROM `doc` WHERE School_ID = ?";
    con.query(
      selectDocumentsSql,
      [schoolId],
      function (err, docResult, fields) {
        if (err) {
          console.log("Error retrieving school documents:", err);
          res.status(500).send("Internal Server Error");
          return;
        }

        // Prepare the response object with the school's information and documents
        const response = {
          schoolId: school.School_ID,
          schoolName: school.School_Name,
          email: school.Email,
          contact: school.Contact,
          address: school.address,
          profileImage: school.Profile_image,
          password: school.password,
          license: school.License,
          registrationDate: school.Registration_Date,
          status: school.status,
          documents: docResult,
        };

        res.status(200).json(response);
      }
    );
  });
});

//login API for the app

app.post("/login", (req, res) => {
  var userData = req.body;
  var userEmail = userData?.email;
  var userPassword = userData?.password;

  // Check if email and password match in the database
  var checkCredentialsSql =
    "SELECT * FROM `student` WHERE `Email` = ? AND `password` = ?";
  con.query(
    checkCredentialsSql,
    [userEmail, userPassword],
    function (err, result, fields) {
      if (err) {
        console.log("Error checking credentials:", err);
        res.status(500).send("Internal Server Error");
        return;
      }

      if (result.length > 0) {
        res.status(200).send({ message: "Login Successful." });
      } else {
        res.status(401).send("Invalid credentials.");
      }
    }
  );
});

app.get("/getSchools", (req, res) => {
  con.query(
    "SELECT School_ID, license FROM school WHERE status = 'accepted'",
    function (err, result, fields) {
      if (err) {
        console.log("Error fetching schools:", err);
        return res.status(500).send("Internal Server Error");
      }
      res.send(result);
    }
  );
});

app.get("/getPendingSchools", (req, res) => {
  con.query(
    "SELECT * FROM school WHERE status = 'pending'",
    function (err, result, fields) {
      if (err) {
        console.log("Error fetching pending schools:", err);
        return res.status(500).send("Internal Server Error");
      }
      const pendingSchools = result.map((school) => school.School_Name);
      res.send(pendingSchools);
    }
  );
});

app.put("/updateSchoolStatus", (req, res) => {
  const { schoolName, newStatus } = req.body; // Assuming you receive the school name and new status in the request body

  // Check if the school name exists
  con.query(
    "SELECT School_Name FROM school WHERE School_Name = ?",
    [schoolName],
    function (err, result) {
      if (err) {
        console.log("Error checking if school name exists:", err);
        return res.status(500).send("Internal Server Error");
      }

      if (result.length === 0) {
        // School name does not exist
        return res.status(404).send("School not found");
      }

      // School name exists; proceed to update the status
      con.query(
        "UPDATE school SET status = ? WHERE School_Name = ?",
        [newStatus, schoolName],
        function (err, result) {
          if (err) {
            console.log("Error updating school status:", err);
            return res.status(500).send("Internal Server Error");
          }
          res.send("Status updated successfully");
        }
      );
    }
  );
});

app.get("/getRejectedSchools", (req, res) => {
  con.query(
    "SELECT School_Name FROM school WHERE status = 'rejected'",
    function (err, result, fields) {
      if (err) {
        console.log("Error fetching rejected schools:", err);
        return res.status(500).send("Internal Server Error");
      }
      const rejectedSchools = result.map((school) => school.School_Name);
      res.send(rejectedSchools);
    }
  );
});

app.get("/getApprovedSchools", (req, res) => {
  con.query(
    "SELECT School_Name FROM school WHERE status = 'accepted'",
    function (err, result, fields) {
      if (err) {
        console.log("Error fetching approved schools:", err);
        return res.status(500).send("Internal Server Error");
      }
      const approvedSchools = result.map((school) => school.School_Name);
      res.send(approvedSchools);
    }
  );
});

app.get("/getSchool", (req, res) => {
  con.query(
    "SELECT * FROM school WHERE status = 'Accepted'",
    function (err, result, fields) {
      if (err) {
        console.log("Error fetching schools:", err);
        return res.status(500).send("Internal Server Error");
      }
      res.send(result);
    }
  );
});

app.get("/getPending", (req, res) => {
  con.query(
    "SELECT * FROM school WHERE status = 'Pending'",
    function (err, result, fields) {
      if (err) {
        console.log("Error fetching schools:", err);
        return res.status(500).send("Internal Server Error");
      }
      res.send(result);
    }
  );
});
app.post("/createNewSchool1", (req, res) => {
  var userData = req.body;
  var userName = userData?.name;
  var userEmail = userData?.email;
  var useraddress = userData?.address;
  var usercontact = userData?.phone;
  var userprofile = userData?.imageData;
  var userLisence = userData?.documentData;
  var userPassword = userData?.password;
  var userId = Math.floor(Math.random() * 10000) + 1;

  // Additional Fields// Set initial status as pending
  var userAdmission = userData?.admissionData;
  var userProspectus = userData?.prospectusData;
  var userHeadOfInstitution = userData?.headofinstitutionData;
  var userTeacher1 = userData?.teacher1Data;
  var userTeacher2 = userData?.teacher2Data;
  var userImage1 = userData?.image1Data;
  var userImage2 = userData?.image2Data;
  var userImage3 = userData?.image3Data;
  var userImage4 = userData?.image4Data;
  var userImage5 = userData?.image5Data;
  var userImage6 = userData?.image6Data;
  var userDescription = userData?.description;

  // Check if email already exists
  var checkEmailSql = "SELECT * FROM `school` WHERE `Email` = ?";
  const schoolID = "your_generated_school_id_here";
  con.query(checkEmailSql, [userEmail], function (err, result, fields) {
    if (err) {
      console.log("Error checking email:", err);
      res.status(500).send("Internal Server Error");
      return;
    }

    if (result.length > 0) {
      res.status(400).send("Email already exists");
      return;
    }

    // Insert new account
    var insertSql =
      "INSERT INTO `school`(`School_ID`, `School_Name`, `Email`, `Contact`, `address`, `Profile_image`, `password`, `License`, `admission`, `prospectus`, `headofinstitution`, `teacher1`, `teacher2`, `image1`, `image2`, `image3`, `image4`, `image5`, `image6`, `discription`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    con.query(
      insertSql,
      [
        userId,
        userName,
        userEmail,
        usercontact,
        useraddress,
        userprofile,
        userPassword,
        userLisence,
        userAdmission,
        userProspectus,
        userHeadOfInstitution,
        userTeacher1,
        userTeacher2,
        userImage1,
        userImage2,
        userImage3,
        userImage4,
        userImage5,
        userImage6,
        userDescription,
      ],
      function (err, result, fields) {
        if (err) {
          console.log("Error creating account:", err);
          res.status(500).send("Internal Server Error");
          return;
        }

        res
          .status(200)
          .send({ message: "Account Created Successfully.", id: schoolID });
      }
    );
  });
});

app.post("/createNewSchool", (req, res) => {
  var userData = req.body;
  var userName = userData?.name;
  var userEmail = userData?.email;
  var useraddress = userData?.address;
  var usercontact = userData?.phone;
  var userprofile = userData?.imageData;
  var userLisence = userData?.documentData;
  var userPassword = userData?.password;
  var userId = Math.floor(Math.random() * 10000) + 1;

  // Check if email already exists
  var checkEmailSql = "SELECT * FROM `school` WHERE `Email` = ?";
  const schoolID = "your_generated_school_id_here";
  con.query(checkEmailSql, [userEmail], function (err, result, fields) {
    if (err) {
      console.log("Error checking email:", err);
      res.status(500).send("Internal Server Error");
      return;
    }

    if (result.length > 0) {
      res.status(400).send("Email already exists");
      return;
    }
    // Insert new account
    var insertSql =
      "INSERT INTO `school`(`School_ID`, `School_Name`, `Email`, `Contact`, `address`, `Profile_image`, `password`, `License`) VALUES (?, ?, ? ,? ,? ,? ,? ,?)";
    con.query(
      insertSql,
      [
        userId,
        userName,
        userEmail,
        usercontact,
        useraddress,
        userprofile,
        userPassword,
        userLisence,
      ],
      function (err, result, fields) {
        if (err) {
          console.log("Error creating account:", err);
          res.status(500).send("Internal Server Error");
          return;
        }

        res
          .status(200)
          .send({ message: "Account Created Successfully.", id: schoolID });
      }
    );
  });
});
// Import necessary modules and set up your express app and database connection

app.put("/updateSchool", (req, res) => {
  const userEmail = req.body.email;
  const updatedFields = req.body.updatedFields; // An object containing the fields to update
  // Validate userEmail and updatedFields
  if (!userEmail || !updatedFields) {
    res.status(400).send("Invalid request data");
    return;
  }

  // Construct the SQL query to update the fields based on the provided email
  const updateSql = "UPDATE `school` SET ? WHERE `Email` = ?";
  con.query(
    updateSql,
    [updatedFields, userEmail],
    function (err, result, fields) {
      if (err) {
        console.log("Error updating fields:", err);
        res.status(500).send("Internal Server Error");
        return;
      }

      res.status(200).send({ message: "Fields updated successfully." });
    }
  );
});

//new info

app.post("/updateSchoolInfo", (req, res) => {
  var userData = req.body;
  var userEmail = userData?.email;
  var userDescription = userData?.description;
  var userProspectus = userData?.prospectus;
  var userAdmissionInfo = userData?.admissionInfo;
  var userHod = userData?.hod;
  var userTeacher1 = userData?.teacher1;
  var userTeacher2 = userData?.teacher2;

  // Update school information
  var updateSql =
    "UPDATE `school` SET `Description` = ?, `prospectus` = ?, `admission` = ?, `head` = ?, `teacher1` = ?, `teacher2` = ? WHERE `Email` = ?";
  con.query(
    updateSql,
    [
      userDescription,
      userProspectus,
      userAdmissionInfo,
      userHod,
      userTeacher1,
      userTeacher2,
      userEmail,
    ],
    function (err, result, fields) {
      if (err) {
        console.log("Error updating school info:", err);
        res.status(500).send("Internal Server Error");
        return;
      }

      res
        .status(200)
        .send({ message: "School information updated successfully." });
    }
  );
});

//Schoool Login

app.post("/schoolLogin", (req, res) => {
  var userData = req.body;
  var userEmail = userData?.email;
  var userPassword = userData?.password;

  // Check if email and password match in the database for the school table
  var checkCredentialsSql =
    "SELECT * FROM `school` WHERE `Email` = ? AND `password` = ?";
  con.query(
    checkCredentialsSql,
    [userEmail, userPassword],
    function (err, result, fields) {
      if (err) {
        console.log("Error checking credentials:", err);
        res.status(500).send("Internal Server Error");
        return;
      }

      if (result.length > 0) {
        res.status(200).send({ message: "School Login Successful." });
      } else {
        res.status(401).send("Invalid credentials.");
      }
    }
  );
});

// app.post('/hope', (req, res) => {
//   var userData = req.body;
//   var userEmail = userData?.email;
//   var userPassword = userData?.password;

//   // Check if email and password match in the `student` table
//   var checkStudentCredentialsSql = "SELECT * FROM `student` WHERE `Email` = ? AND `password` = ?";
//   con.query(checkStudentCredentialsSql, [userEmail, userPassword], function (err, studentResult, fields) {
//     if (err) {
//       console.log("Error checking student credentials:", err);
//       return res.status(500).send("Internal Server Error");
//     }

//     // If the user is found in the `student` table, respond with login success
//     if (studentResult.length > 0) {
//       return res.status(200).send({ message: "Login Successful." });
//     } else {
//       // If the user is not found in the `student` table, check the `school` table
//       var checkSchoolCredentialsSql = "SELECT * FROM `school` WHERE `Email` = ? AND `password` = ?";
//       con.query(checkSchoolCredentialsSql, [userEmail, userPassword], function (err, schoolResult, fields) {
//         if (err) {
//           console.log("Error checking school credentials:", err);
//           return res.status(500).send("Internal Server Error");
//         }

//         // If the user is found in the `school` table, respond with login success
//         if (schoolResult.length > 0) {
//           return res.status(200).send({ message: "School Login Successful." });
//         } else {
//           // If the user is not found in either table, respond with login failure
//           return res.status(401).send("Invalid credentials.");
//         }
//       });
//     }
//   });
// });
// app.post("/hope", (req, res) => {
//   var userData = req.body;
//   var userEmail = userData?.email;
//   var userPassword = userData?.password;

//   // Check if email and password match in the `student` table
//   var checkStudentCredentialsSql =
//     "SELECT * FROM `student` WHERE `Email` = ? AND `password` = ?";
//   con.query(
//     checkStudentCredentialsSql,
//     [userEmail, userPassword],
//     function (err, studentResult, fields) {
//       if (err) {
//         console.log("Error checking student credentials:", err);
//         return res.status(500).send("Internal Server Error");
//       }

//       // If the user is found in the `student` table, respond with login success and the user's role
//       if (studentResult.length > 0) {
//         return res.status(200).send({
//           message: "Login Successful.",
//           role: "student", // Include the user's role here
//         });
//       } else {
//         // If the user is not found in the `student` table, check the `school` table
//         var checkSchoolCredentialsSql =
//           "SELECT * FROM `school` WHERE `Email` = ? AND `password` = ?";
//         con.query(
//           checkSchoolCredentialsSql,
//           [userEmail, userPassword],
//           function (err, schoolResult, fields) {
//             if (err) {
//               console.log("Error checking school credentials:", err);
//               return res.status(500).send("Internal Server Error");
//             }

//             // If the user is found in the `school` table and the status is "accepted", respond with login success and the user's role
//             if (
//               schoolResult.length > 0 &&
//               schoolResult[0].status === "Accepted"
//             ) {
//               return res.status(200).send({
//                 message: "School Login Successful.",
//                 role: "school", // Include the user's role here
//               });
//             } else {
//               // If the user is not found in either table or the status is not "accepted", respond with login failure
//               return res.status(401).send("Invalid credentials.");
//             }
//           }
//         );
//       }
//     }
//   );
// });

app.post("/hope", (req, res) => {
  var userData = req.body;
  var userEmail = userData?.email;
  var userPassword = userData?.password;

  // Check if email and password match in the `student` table
  var checkStudentCredentialsSql =
    "SELECT * FROM `student` WHERE `Email` = ? AND `password` = ?";
  con.query(
    checkStudentCredentialsSql,
    [userEmail, userPassword],
    function (err, studentResult, fields) {
      if (err) {
        console.log("Error checking student credentials:", err);
        return res.status(500).send("Internal Server Error");
      }

      // If the user is found in the `student` table, respond with login success and the user's role
      if (studentResult.length > 0) {
        return res.status(200).send({
          message: "Login Successful.",
          role: "student", // Include the user's role here
        });
      } else {
        // If the user is not found in the `student` table, check the `school` table
        var checkSchoolCredentialsSql =
          "SELECT * FROM `school` WHERE `Email` = ? AND `password` = ?";
        con.query(
          checkSchoolCredentialsSql,
          [userEmail, userPassword],
          function (err, schoolResult, fields) {
            if (err) {
              console.log("Error checking school credentials:", err);
              return res.status(500).send("Internal Server Error");
            }

            // If the user is found in the `school` table
            if (schoolResult.length > 0) {
              if (schoolResult[0].status === "Accepted") {
                return res.status(200).send({
                  message: "School Login Successful.",
                  role: "school", // Include the user's role here
                });
              } else if (schoolResult[0].status === "Pending") {
                return res.status(402).send({
                  message: "School is still in pending status.",
                  role: "school", // Include the user's role here
                });
              } else if (schoolResult[0].status === "Rejected") {
                return res.status(403).send({
                  message: "School is in rejected status.",
                  role: "school", // Include the user's role here
                });
              }
            } else {
              // If the user is not found in the `school` table, or the status is not "Accepted," "Pending," or "Rejected", respond with login failure
              return res.status(401).send("Invalid credentials.");
            }
          }
        );
      }
    }
  );
});

// CHATBOX API
app.post("/sendMessage", (req, res) => {
  var messageData = req.body;
  var senderID = messageData?.senderID;
  var receiverID = messageData?.receiverID;
  var messageContent = messageData?.messageContent;
  var timestamp = new Date(); // You can customize the timestamp format as per your requirements

  // Insert the chat message into the chatbox table
  var insertSql =
    "INSERT INTO `chatbox`(`Sender_ID`, `Receiver_ID`, `Message_Content`, `TimeStamp`) VALUES (?, ?, ?, ?)";
  con.query(
    insertSql,
    [senderID, receiverID, messageContent, timestamp],
    function (err, result, fields) {
      if (err) {
        console.log("Error inserting chat message:", err);
        res.status(500).send("Internal Server Error");
        return;
      }

      res.status(200).send({ message: "Chat message sent successfully." });
    }
  );
});

app.post("/sendMessages", (req, res) => {
  var messageData = req.body;
  var senderID = messageData?.senderID;
  // var receiverID = messageData?.receiverID;
  var messageContent = messageData?.messageContent;
  var timestamp = new Date();

  // Retrieve sender and receiver information from the 'student' table
  var selectSenderSql =
    "SELECT `Student_ID`, `Student_Name`, `Email` FROM `student` WHERE `Student_ID` = ?";
  // var selectReceiverSql = "SELECT `Student_ID`, `Student_Name`, `Email` FROM `student` WHERE `Student_ID` = ?";

  con.query(selectSenderSql, [senderID], function (senderErr, senderResult) {
    if (senderErr) {
      console.log("Error retrieving sender information:", senderErr);
      res.status(500).send("Internal Server Error");
      return;
    }

    con.query(
      selectReceiverSql,
      [receiverID],
      function (receiverErr, receiverResult) {
        if (receiverErr) {
          console.log("Error retrieving receiver information:", receiverErr);
          res.status(500).send("Internal Server Error");
          return;
        }

        // Insert the chat message into the chatbox table
        var insertSql =
          "INSERT INTO `chatbox`(`Sender_ID`, `Receiver_ID`, `Message_Content`, `TimeStamp`) VALUES (?, ?, ?, ?)";
        con.query(
          insertSql,
          [senderID, receiverID, messageContent, timestamp],
          function (insertErr, insertResult, fields) {
            if (insertErr) {
              console.log("Error inserting chat message:", insertErr);
              res.status(500).send("Internal Server Error");
              return;
            }

            res.status(200).send({
              message: "Chat message sent successfully.",
              sender: senderResult[0],
              receiver: receiverResult[0],
            });
          }
        );
      }
    );
  });
});

app.post("/chat", (req, res) => {
  const userEmail = req.body.email;
  const messageContent = req.body.message;

  // Retrieve Student_ID based on the provided email
  const getStudentIdSql = "SELECT Student_ID FROM student WHERE Email = ?";
  con.query(getStudentIdSql, [userEmail], function (err, result, fields) {
    if (err) {
      console.log("Error fetching student ID:", err);
      return res.status(500).send("Internal Server Error");
    }

    if (result.length === 0) {
      return res.status(404).send("Student not found");
    }

    const studentId = result[0].Student_ID;

    // Insert the message with the retrieved Student_ID
    const insertMessageSql =
      "INSERT INTO chatbox (Student_ID, Message_Content) VALUES (?, ?)";
    con.query(
      insertMessageSql,
      [studentId, messageContent],
      function (err, result, fields) {
        if (err) {
          console.log("Error inserting message:", err);
          return res.status(500).send("Error inserting message");
        }

        return res.status(200).send("Message sent successfully");
      }
    );
  });
});

//Newfeeds

//  app.post('/NewFeeds', (req, res) => {
//     var userData = req.body;
//     var userDescription = userData?.description;
//     var userprospectus = userData?.prospectus;
//     var useraddmission = userData?.addmission;
//     var userbuildingphotos = userData?.photos;
//     var userteachers = userData?.teachers;
//     var userId = Math.floor(Math.random() * 10000) + 1;

//       var selectSchoolSql = "SELECT `School_ID`, `School_Name`, `Email`, `Contact`, `address` FROM `school` WHERE `School_ID` = ?";

//       con.query(selectSchoolSql, [schoolID], function (schoolErr, schoolResult) {
//       if (schoolErr) {
//         console.log("Error retrieving school information:", schoolErr);
//         res.status(500).send("Internal Server Error");
//         return;
//       }
//       // Insert new account
//       var insertSql = "INSERT INTO `doc`(`Docum_ID`, `Description`, `prospectus_document`, `Admission_document`, `building_images`, `Teachers`) VALUES (?, ? ,? ,? ,? ,?)";
//       con.query(insertSql, [userId, userDescription, userprospectus, useraddmission,  JSON.stringify(userbuildingphotos),  JSON.stringify(userteachers)], function (err, result, fields) {
//         if (err) {
//           console.log("Error creating account:", err);
//           res.status(500).send("Internal Server Error");
//           return;
//         }

//         res.status(200).send({ message: "updated succesfully" });
//       });
//     });
// // });
// new feeds
app.post("/NewFeeds", (req, res) => {
  var userData = req.body;
  var userDescription = userData?.description;
  var userprospectus = userData?.prospectus;
  var useraddmission = userData?.addmission;
  var userbuildingphotos = userData?.photos;
  var userteachers = userData?.teachers;
  var schoolID = userData?.schoolID; // Retrieve schoolID from the request body

  var userId = Math.floor(Math.random() * 10000) + 1;

  var insertSql =
    "INSERT INTO `doc`(`Docum_ID`, `School_ID`, `Description`, `prospectus_document`, `Admission_document`, `building_images`, `Teachers`) VALUES (?, ?, ?, ?, ?, ?, ?)";
  con.query(
    insertSql,
    [
      userId,
      schoolID,
      userDescription,
      userprospectus,
      useraddmission,
      JSON.stringify(userbuildingphotos),
      JSON.stringify(userteachers),
    ],
    function (err, result, fields) {
      if (err) {
        console.log("Error creating account:", err);
        res.status(500).send("Internal Server Error");
        return;
      }

      res.status(200).send({ message: "updated successfully" });
    }
  );
});

//fetch account

const schoolAccount = {
  School_ID: "999",
  School_Name: "Punjab College",
  Email: "main@gmail.com",
  Contact: "0987",
  Address: "address",
  Profile_Image: "[BLOB - 487.8 KiB]",
  Password: "0987",
};

// API endpoint to fetch school account details
app.get("/gh", (req, res) => {
  // You can fetch the data from a database or external data source here
  // For this example, we'll just return the sample school account data
  res.json(schoolAccount);
});
// FEEDBACK API
app.post("/Feedback", (req, res) => {
  var feedbackData = req.body;
  var feedbackText = feedbackData?.Feedback_text;
  var studentEmail = feedbackData?.Student_Email; // User provides email
  var schoolName = feedbackData?.School_Name; // User provides school name
  var timestamp = new Date();

  // Retrieve student ID based on the provided email
  var selectStudentSql = "SELECT `Student_ID` FROM `student` WHERE `Email` = ?";

  con.query(
    selectStudentSql,
    [studentEmail],
    function (studentErr, studentResult) {
      if (studentErr) {
        console.log("Error retrieving student information:", studentErr);
        res.status(500).send("Internal Server Error");
        return;
      }

      if (studentResult.length === 0) {
        // Handle the case where the provided email doesn't exist
        res.status(404).send("Student not found with the provided email");
        return;
      }

      // Retrieve school ID based on the provided school name
      var selectSchoolSql =
        "SELECT `School_ID` FROM `school` WHERE `School_Name` = ?";

      con.query(
        selectSchoolSql,
        [schoolName],
        function (schoolErr, schoolResult) {
          if (schoolErr) {
            console.log("Error retrieving school information:", schoolErr);
            res.status(500).send("Internal Server Error");
            return;
          }

          if (schoolResult.length === 0) {
            // Handle the case where the provided school name doesn't exist
            res.status(404).send("School not found with the provided name");
            return;
          }

          var studentID = studentResult[0].Student_ID;
          var schoolID = schoolResult[0].School_ID;

          // Insert feedback into the database
          var insertSql =
            "INSERT INTO `feedback`(`Feedback_text`, `Student_ID`, `School_ID`, `TimeStamp`) VALUES (?, ?, ?, ?)";

          con.query(
            insertSql,
            [feedbackText, studentID, schoolID, timestamp],
            function (insertErr, insertResult, fields) {
              if (insertErr) {
                console.log("Error inserting feedback:", insertErr);
                res.status(500).send("Internal Server Error");
                return;
              }

              res.status(200).send({
                message: "Feedback submitted successfully.",
                student: { Student_ID: studentID },
                school: { School_ID: schoolID },
              });
            }
          );
        }
      );
    }
  );
});

//feedback
app.post("/submitFeedback", (req, res) => {
  var feedbackData = req.body;
  var feedbackID = feedbackData?.Feedback_ID;
  var feedbackText = feedbackData?.Feedback_text;
  var studentIdentifier = feedbackData?.Student_Identifier; // Accepts either student ID or student name
  var schoolID = feedbackData?.School_ID;
  var timestamp = new Date();

  var selectStudentSql =
    "SELECT `Student_ID`, `Student_Name`, `Email` FROM `student` WHERE `Student_ID` = ? OR `Student_Name` = ?";
  var selectSchoolSql =
    "SELECT `School_ID`, `School_Name`, `Email`, `Contact`, `address` FROM `school` WHERE `School_ID` = ?";

  con.query(
    selectStudentSql,
    [studentIdentifier, studentIdentifier],
    function (studentErr, studentResult) {
      if (studentErr) {
        console.log("Error retrieving student information:", studentErr);
        res.status(500).send("Internal Server Error");
        return;
      }

      con.query(
        selectSchoolSql,
        [schoolID],
        function (schoolErr, schoolResult) {
          if (schoolErr) {
            console.log("Error retrieving school information:", schoolErr);
            res.status(500).send("Internal Server Error");
            return;
          }

          var student = studentResult[0];

          if (!student) {
            // If student not found
            res.status(404).send("Student not found");
            return;
          }

          var studentID = student.Student_ID;

          var insertSql =
            "INSERT INTO `feedback`(`Feedback_ID`, `Feedback_text`, `Student_ID`, `School_ID`, `TimeStamp`) VALUES (?, ?, ?, ?, ?)";

          con.query(
            insertSql,
            [feedbackID, feedbackText, studentID, schoolID, timestamp],
            function (insertErr, insertResult, fields) {
              if (insertErr) {
                console.log("Error inserting feedback:", insertErr);
                res.status(500).send("Internal Server Error");
                return;
              }

              res.status(200).send({
                message: "Feedback submitted successfully.",
                student: student,
                school: schoolResult[0],
              });
            }
          );
        }
      );
    }
  );
});

app.post("/h", (req, res) => {
  var userData = req.body;
  var userEmail = userData?.email;
  var userPassword = userData?.password;

  // Check if email and password match in the `student` table
  var checkStudentCredentialsSql =
    "SELECT * FROM `student` WHERE `Email` = ? AND `password` = ?";
  con.query(
    checkStudentCredentialsSql,
    [userEmail, userPassword],
    function (err, studentResult, fields) {
      if (err) {
        console.log("Error checking student credentials:", err);
        return res.status(500).send("Internal Server Error");
      }

      // If the user is found in the `student` table, respond with login success
      if (studentResult.length > 0) {
        return res.status(200).send({ message: "Login Successful." });
      } else {
        // If the user is not found in the `student` table, check the `school` table
        var checkSchoolCredentialsSql =
          "SELECT * FROM `school` WHERE `Email` = ? AND `password` = ?";
        con.query(
          checkSchoolCredentialsSql,
          [userEmail, userPassword],
          function (err, schoolResult, fields) {
            if (err) {
              console.log("Error checking school credentials:", err);
              return res.status(500).send("Internal Server Error");
            }

            // If the user is found in the `school` table and is approved (status = 'Accepted'), respond with login success
            if (
              schoolResult.length > 0 &&
              schoolResult[0].status === "Accepted"
            ) {
              return res
                .status(200)
                .send({ message: "School Login Successful." });
            } else if (
              schoolResult.length > 0 &&
              schoolResult[0].status === "Pending"
            ) {
              // If the user is found in the `school` table but the status is 'Pending', respond with pending status
              return res
                .status(200)
                .send({ message: "School Request is Pending Approval." });
            } else {
              // If the user is not found in either table or the status is 'Rejected', respond with login failure
              return res
                .status(401)
                .send("Invalid credentials or School not approved.");
            }
          }
        );
      }
    }
  );
});

app.post("/requests", (req, res) => {
  var schoolId = req.body.schoolId;
  var approvalStatus = req.body.approvalStatus; // "Accepted" or "Rejected"

  // Update the `status` column in the `school` table based on the provided schoolId
  var updateStatusSql =
    "UPDATE `school` SET `status` = ? WHERE `School_ID` = ?";
  con.query(
    updateStatusSql,
    [approvalStatus, schoolId],
    function (err, result, fields) {
      if (err) {
        console.log("Error updating school status:", err);
        return res.status(500).send("Internal Server Error");
      }

      if (result.affectedRows > 0) {
        return res.status(200).send({
          message: "School request approval status updated successfully.",
        });
      } else {
        return res
          .status(404)
          .send({ message: "School not found or update failed." });
      }
    }
  );
});

app.get("/pendingSchools", (req, res) => {
  // Retrieve schools with status as 'Pending' from the database
  var selectPendingSchoolsSql =
    "SELECT School_Name, Email, Contact, address, Profile_image, License, Registration_Dtae FROM `school` WHERE `status` = 'Pending'";

  con.query(selectPendingSchoolsSql, function (err, result, fields) {
    if (err) {
      console.log("Error retrieving pending schools:", err);
      res.status(500).send("Internal Server Error");
      return;
    }

    // Prepare the response object with the pending schools' information
    var response = result.map((school) => ({
      schoolName: school.School_Name,
      email: school.Email,
      contact: school.Contact,
      address: school.address,
      profileImage: school.Profile_image,
      license: school.License,
      registrationDate: school.Registration_Dtae,
      // Add other fields as needed
    }));

    res.status(200).send(response);
  });
});

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "ammaryasirkhan5@gmail.com",
    pass: "jqrs oywz uumb wxkt",
  },
});

// Define the generateRandomCode function in the same scope
function generateRandomCode() {
  const length = 5; // You can adjust the code length as needed
  const charset =
    "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
  let code = "";

  for (let i = 0; i < length; i++) {
    const randomIndex = Math.floor(Math.random() * charset.length);
    code += charset[randomIndex];
  }

  return code;
}
app.post("/send", async (req, res) => {
  const userEmail = req.body.email;

  // Check if the user's email exists in the database
  const checkEmailQuery = "SELECT Student_ID FROM student WHERE Email = ?";
  con.query(checkEmailQuery, [userEmail], (error, results) => {
    if (error) {
      return res.status(500).json({ message: "internal server error" });
    }

    if (results.length === 0) {
      return res
        .status(400)
        .json({ message: "No account found with this email!" });
    }

    // Generate a random reset code
    const resetCode = generateRandomCode();

    // Save the reset code in the MySQL database
    const saveCodeQuery = "UPDATE student SET ResetCode = ? WHERE Email = ?";
    con.query(saveCodeQuery, [resetCode, userEmail], (error, results) => {
      if (error) {
        return res.status(500).json({ message: "Database update error" });
      }

      // Send the email
      const mailOptions = {
        from: "your-email@gmail.com",
        to: userEmail,
        subject: "Password Reset",
        text: `Your password reset code is: ${resetCode}`,
      };

      transporter.sendMail(mailOptions, (error, info) => {
        if (error) {
          return res.status(500).json({ message: "Email sending error" });
        }
        res.json({ message: "Password reset email sent" });
      });
    });
  });
});
//Reset Password

app.post("/reset-password", async (req, res) => {
  const { email, verificationCode, newPassword } = req.body;

  // Check if the provided verification code matches the code in the database
  const checkCodeQuery =
    "SELECT Student_ID FROM student WHERE Email = ? AND ResetCode = ?";
  con.query(checkCodeQuery, [email, verificationCode], (error, results) => {
    if (error) {
      return res.status(500).json({ message: "Database error" });
    }

    if (results.length === 0) {
      return res.status(400).json({ message: "Invalid verification code" });
    }

    // Update the password for the user
    const updatePasswordQuery =
      "UPDATE student SET Password = ? WHERE Email = ?";
    con.query(updatePasswordQuery, [newPassword, email], (error, results) => {
      if (error) {
        return res.status(500).json({ message: "Database error" });
      }

      res.json({ message: "Password reset successful" });
    });
  });
});

app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});
